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
    Clock
}

import org.jsimpledb {
    JTransaction,
    JSimpleDBFactory,
    ValidationMode {
        automatic
    }
}
import org.jsimpledb.core {
    Database,
    FieldType
}
import org.jsimpledb.kv.simple {
    SimpleKVDatabase
}

shared class ContextImpl(transaction, clock, config) satisfies Context {
    shared JTransaction transaction;
    shared Clock clock;
    shared Toml config;
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
    Module subject = `module`
) {
    value modelClasses = subject
        .findServiceProviders(`ModelClassProvider`)
        .map((provider) => javaClassFromModel(provider.modelClass));
    value fieldTypes = subject
        .findServiceProviders(`FieldTypeProvider`)
        .map((provider) => provider.fieldType);
    value kvdb = SimpleKVDatabase();
    value db = Database(kvdb);
    for (fieldType in fieldTypes) {
        db.fieldTypeRegistry.add(fieldType);
    }
    value jdb = JSimpleDBFactory()
        .setSchemaVersion(-1)
        .setModelClasses(*modelClasses)
        .setDatabase(db)
        .newJSimpleDB();
    value clock = Clock.systemUTC();

    shared T withContext<T>(T run(Context ctx)) {
        value tx = jdb.createTransaction(true, automatic);
        try {
            value result = run(ContextImpl(tx, clock, config));
            if (commit) {
                tx.commit();
            }
            return result;
        } finally {
            tx.rollback();
        }
    }
}

shared T withTestContext<T>(Module modelClassesModule, T run(Context ctx)) {
    value provider = TestContextProvider {
        subject = modelClassesModule;
    };
    return provider.withContext(run);
}