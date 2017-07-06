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

shared abstract class ContextImpl(transaction, clock, config) satisfies Context {
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
    Module subject = `module`,
    Boolean commit = false,
    Toml config = Toml(),
    Clock clock = Clock.fixed(Instant.epoch, ZoneOffset.utc)
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

    shared class NewContext() extends ContextImpl(
        jdb.createTransaction(true, automatic),
        outer.clock,
        outer.config
    ) {
        shared actual void destroy(Throwable? error) {
            if (!exists error, commit) {
                transaction.commit();
            } else {
                transaction.rollback();
            }
        }
    }
}