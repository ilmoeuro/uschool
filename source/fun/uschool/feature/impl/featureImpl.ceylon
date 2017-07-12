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
    JObject
}
import org.jsimpledb.core {
    FieldType
}

shared interface ModelClassProvider {
    shared formal ClassOrInterface<Object> modelClass;
}

shared interface FieldTypeProvider {
    shared formal FieldType<out Object> fieldType;
}

shared class AlreadyReleasedException() extends Exception(
    "Context is already released"
) {
}

shared abstract class AppContext(transaction, clock, config)
        satisfies Context & Destroyable {

    shared JTransaction transaction;
    shared Clock clock;
    shared Toml config;
    
    shared formal void commit();
    shared formal void rollback();
}

shared Active(Context) loader<Passive, Active>(
    ClassOrInterface<Passive> cls,
    Active(Context)(Passive) activate,
    Passive(Active) passivate,
    Active obj
)
given Passive satisfies Object
given Active satisfies Object {
    Passive passive = passivate(obj);
    "`passive` should be JObject"
    assert(is JObject passive);
    value objId = passive.objId;
    
    Active load(Context context) {
        assert (is AppContext context);
        Passive result = context.transaction.get(objId, cls);
        return activate(result)(context);
    }
    
    return load;
}