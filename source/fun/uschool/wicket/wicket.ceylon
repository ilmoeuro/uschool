/*
    uschool - worldwide learning platform
    Copyright (2017) Ilmo Euro

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
import ceylon.buffer.charset {
    utf8
}
import ceylon.file {
    parsePath
}
import ceylon.interop.java {
    javaClassFromDeclaration,
    createJavaByteArray,
    javaString
}
import ceylon.language.meta.declaration {
    Module,
    ClassDeclaration
}

import com.github.sommeri.less4j {
    LessSource
}
import com.github.sommeri.less4j.core {
    ThreadUnsafeLessCompiler
}

import java.io {
    ByteArrayInputStream
}

import org.apache.wicket.markup.html.panel {
    GenericPanel
}
import org.apache.wicket.model {
    CompoundPropertyModel,
    IModel
}
import org.apache.wicket.request.resource {
    AbstractResource {
        ResourceResponse,
        WriteCallback
    },
    IResource {
        Attributes
    },
    ResourceReference
}
import org.apache.wicket.request.resource.caching {
    IStaticCacheableResource
}
import org.apache.wicket.util.lang {
    Bytes
}
import org.apache.wicket.util.resource {
    AbstractResourceStream
}

shared class CompoundPanel<Model> extends GenericPanel<Model> {
    shared new (id) extends GenericPanel<Model>(id) {
        String id;
    }

    shared new withModel(id, model) extends GenericPanel<Model>(id, model) {
        String id;
        IModel<Model> model;
    }

    shared actual default void onInitialize() {
        super.onInitialize();
        this.model = CompoundPropertyModel(this.model);
    }
}

class ModuleLessSource(Module mod, String path) extends LessSource() {
    Resource resource;
    if (exists res = mod.resourceByPath(path)) {
        resource = res;
    } else {
        throw FileNotFound();
    }

    bytes => createJavaByteArray(utf8.encode(content));
    content => resource.textContent();
    name => path;

    shared actual LessSource relativeSource(String filename) {
        value origPath = parsePath(path);
        value newPath = origPath.siblingPath(filename);
        return ModuleLessSource(mod, newPath.string);
    }
}

shared class LessResource(Module mod, String path)
        extends AbstractResource()
        satisfies IStaticCacheableResource {

    value source = ModuleLessSource(mod, path);
    value compiler = ThreadUnsafeLessCompiler();
    value compiledCss = compiler.compile(source);
    value warningMessages = {
        for (warning in compiledCss.warnings)
            let (file = warning.source.name,
                 row = warning.line,
                 col = warning.character,
                 type = warning.type,
                 msg = warning.message)
                "``file``:``row``:``col``:``type``:``msg``"
    };
    value compiledBytes = createJavaByteArray(utf8.encode(compiledCss.css));

    shared actual ResourceResponse newResourceResponse(Attributes attributes) {
        value result = ResourceResponse();
        result.setContentType("text/css");
        result.setTextEncoding("utf-8");

        for (warning in warningMessages) {
            result.headers.addHeader("Less-Warning-Message", warning);
        }

        object writeCallback extends WriteCallback() {
            shared actual void writeData(Attributes attributes) {
                value outputStream = attributes.response.outputStream;
                outputStream.write(compiledBytes);
            }
        }

        result.setWriteCallback(writeCallback);
        return result;
    }
    
    shared actual object resourceStream extends AbstractResourceStream() {
        shared actual void close() {}
        
        inputStream => ByteArrayInputStream(compiledBytes);
        contentType => "text/css";
        length() => Bytes.bytes(compiledBytes.size);
    }

    cacheKey => javaString(mod.qualifiedName + "::" + path);
    
    cachingEnabled => true;
}

shared class LessResourceReference(decl, path) extends ResourceReference(
    javaClassFromDeclaration(decl),
    path
) {
    ClassDeclaration decl;
    String path;

    resource = LessResource(decl.containingModule, path);
}