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
import ceylon.interop.persistence {
    EntityManager
}
import ceylon.language.meta.model {
    Class
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

shared interface AppContext satisfies Context & Destroyable {
    shared formal EntityManager entityManager;
    shared formal Clock clock;
    shared formal Toml config;
    
    shared formal void commit();
    shared formal void rollback();
}

shared Active(Context) makeLoader<Passive, Active>(
        Class<Passive> entityClass,
        Active(Context)(Passive) activate,
        Object primaryKey)
    given Passive satisfies Object
    given Active satisfies Object {
    
    Active result(Context context) {
        assert (is AppContext context);

        value passive = context.entityManager.find(entityClass, primaryKey);
        assert (exists passive);

        return activate(passive)(context);
    }
    
    return result;
}