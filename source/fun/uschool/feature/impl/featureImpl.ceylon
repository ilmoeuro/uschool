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
import ceylon.interop.java {
    javaClassFromModel
}
import ceylon.language.meta.declaration {
    Module
}
import ceylon.language.meta.model {
    ClassOrInterface
}

import com.moandjiezana.toml {
    Toml
}

import fun.uschool.feature.api {
    Context
}

import java.time {
    Clock,
    Instant,
    ZoneOffset
}

import org.jsimpledb {
    JTransaction,
    JSimpleDBFactory,
    ValidationMode {
        automatic
    }
}
import org.jsimpledb.core {
    FieldType,
    Database
}
import org.jsimpledb.kv.simple {
    SimpleKVDatabase
}

shared class AlreadyReleasedException() extends Exception(
    "Context is already released"
) {
}

shared class ContextImpl(transaction, clock, config, onRelease) satisfies Context {
    shared JTransaction transaction;
    shared Clock clock;
    shared Toml config;
    shared Anything onRelease(Throwable? error);
    variable Boolean released = false;
    
    shared actual void obtain() {
        if (released) {
            throw AlreadyReleasedException();
        }
        
    }
    
    shared actual void release(Throwable? error) {
        onRelease(error);
        released = true;
    }
}

shared interface ModelClassProvider {
    shared formal ClassOrInterface<Object> modelClass;
}

shared interface FieldTypeProvider {
    shared formal FieldType<out Object> fieldType;
}

shared class TestContextProvider(
    Boolean commit = false,
    Toml config = Toml(),
    Clock clock = Clock.fixed(Instant.epoch, ZoneOffset.utc),
    Module subject = `module`
) {
    value modelClasses = subject
        .findServiceProviders(`ModelClassProvider`)
        .map((provider) => javaClassFromModel(provider.modelClass));
    value fieldTypes = subject
        .findServiceProviders(`FieldTypeProvider`)
        .map((provider) => provider.fieldType);
    value kvdb = SimpleKVDatabase(0, 0);
    value db = Database(kvdb);
    for (fieldType in fieldTypes) {
        db.fieldTypeRegistry.add(fieldType);
    }
    value jdb = JSimpleDBFactory()
        .setSchemaVersion(-1)
        .setModelClasses(*modelClasses)
        .setDatabase(db)
        .newJSimpleDB();

    shared Context obtainContext() {
        value tx = jdb.createTransaction(true, automatic);
        value ctx = ContextImpl {
            transaction = tx;
            clock = clock;
            config = config;
            onRelease = (error) {
                if (!exists error, commit) {
                    tx.commit();
                } else {
                    tx.rollback();
                }
            };
        };
        return ctx;
    }
}

shared Context testContext(Module modelClassesModule) {
    value provider = TestContextProvider {
        subject = modelClassesModule;
    };
    return provider.obtainContext();
}