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
import ceylon.interop.java {
    createJavaByteArray
}
import ceylon.language.meta.declaration {
    Module
}

import com.github.sommeri.less4j {
    LessSource
}
import com.github.sommeri.less4j.core {
    ThreadUnsafeLessCompiler
}

import org.apache.wicket.markup.html.panel {
    GenericPanel
}
import org.apache.wicket.model {
    CompoundPropertyModel
}
import org.apache.wicket.request.resource {
    AbstractResource {
        ResourceResponse,
        WriteCallback
    },
    IResource {
        Attributes
    }
}

shared class CompoundPanel<Model>(id) extends GenericPanel<Model>(id) {
    String id;

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

    bytes => createJavaByteArray(
        utf8.encode(
            resource.textContent()));
    content => resource.textContent();
    name => path;

    shared actual LessSource relativeSource(String filename) {
        return ModuleLessSource(mod, filename);
    }
}

shared class LessResource(Module mod, String path) extends AbstractResource() {
    shared actual ResourceResponse newResourceResponse(Attributes attributes) {
        value result = ResourceResponse();
        result.disableCaching(); // TODO caching + cache busting
        result.setContentType("text/css");
        result.setTextEncoding("utf-8");

        value source = ModuleLessSource(mod, path);
        value compiler = ThreadUnsafeLessCompiler();
        value compiledCss = compiler.compile(source);

        for (warning in compiledCss.warnings) {
            value file = warning.source.name;
            value row = warning.line;
            value col = warning.character;
            value type = warning.type;
            value msg = warning.message;
            result.headers.addHeader(
                "X-Less-Warning",
                "``file``:``row``:``col``:``type``:``msg``");
        }

        object writeCallback extends WriteCallback() {
            shared actual void writeData(Attributes attributes) {
                value outputStream = attributes.response.outputStream;
                outputStream.write(
                    createJavaByteArray(
                        utf8.encode(compiledCss.css)));
            }
        }

        result.setWriteCallback(writeCallback);
        return result;
    }
}