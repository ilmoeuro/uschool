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
    javaString
}

import fun.uschool.feature.api {
    Context
}
import fun.uschool.feature.impl {
    AppContext,
    loader
}
import fun.uschool.user.impl {
    UserImpl
}
import fun.uschool.util {
    namedValue
}

import java.lang {
    JString=String
}
import java.time {
    Instant
}

shared interface PassiveUser {
    shared formal class Active(Context ctx) {
        shared formal PassiveUser passive;

        shared formal variable String userName;
        shared formal variable String email;
        shared formal variable Role role;
        shared formal Instant created;
        shared formal Instant modified;
        
        shared formal void password(String password);
        shared formal Boolean hasPassword(String password);
    }
}

shared alias User => PassiveUser.Active;

shared class InvalidRoleNameException() extends Exception(
    "Invalid role name"
) {
    
}

shared class Role of locked | guest | student | moderator | admin {
    
    shared static Role ofName(String name) => namedValue(`Role`, name);

    shared String name;
    
    abstract new named(String name) {
        this.name = name;
    }

    shared new locked extends named("locked") {}
    shared new guest extends named("guest") {}
    shared new student extends named("student") {}
    shared new moderator extends named("moderator") {}
    shared new admin extends named("admin") {}

    string => name;
}

shared User(Context) userLoader(User user) =>
    loader(`UserImpl`, PassiveUser.Active, User.passive, user);

shared User createUser(Context ctx) {
    "Context should be AppContext, was `ctx`"
    assert (is AppContext ctx);
    value tx = ctx.transaction;
    value passive = tx.create(`UserImpl`);
    value result = passive.Active(ctx);
    result.init();
    return result;
}

shared User? findUserByName(Context ctx, String userName) {
    "Context should be AppContext, was `ctx`"
    assert (is AppContext ctx);
    value tx = ctx.transaction;
    value usersIndex = tx.queryIndex(`UserImpl`, "userNameField", `JString`);
    value users = usersIndex.asMap().get(javaString(userName));
    if (exists users, !users.empty) {
        return users.first().Active(ctx);
    } else {
        return null;
    }
}