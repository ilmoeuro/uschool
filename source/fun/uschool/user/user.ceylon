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
    javaString,
    createJavaByteArray
}

import com.moandjiezana.toml {
    Toml
}

import fun.uschool.feature.api {
    Context,
    ModelClassNameProvider
}
import fun.uschool.feature.impl {
    AppContext,
    makeLoader
}
import fun.uschool.util {
    namedValue
}

import java.lang {
    ByteArray,
    Long
}
import java.security {
    SecureRandom
}
import java.time {
    Instant
}

import javax.crypto {
    SecretKeyFactory
}
import javax.crypto.spec {
    PBEKeySpec
}
import javax.persistence {
    entity,
    namedQueries,
    namedQuery,
    id,
    generatedValue,
    transient,
    preUpdate,
    GenerationType {
        identity
    }
}

shared alias User => UserEntity.Active;

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

    string => "Role(``name``)";
}

shared User createUser(Context ctx) =>
    UserEntity.createUser(ctx);

shared User? findUserByName(Context ctx, String userName) {
    assert (is AppContext ctx);
    
    value query = ctx.entityManager.createNamedTypedQuery(
        "findUserByName",
        `UserEntity`);
    query.setParameter("userName", userName);
    value results = query.getResults();
    return results.first?.Active(ctx);
}

Integer saltBytes = 32;
Integer keyLength = saltBytes * 8;
String secretKeyAlgorithm = "PBKDF2WithHmacSHA512";

ByteArray pbkdf2(String password, ByteArray salt, Integer numIterations) {
    SecretKeyFactory secretKeyFactory =
            SecretKeyFactory.getInstance(secretKeyAlgorithm);
    value ks = PBEKeySpec(
        javaString(password).toCharArray(),
        salt,
        numIterations,
        keyLength
    );
    value key = secretKeyFactory.generateSecret(ks).encoded;
    return key;
}

Boolean slowEquals(ByteArray a, ByteArray b) {
    variable value diff = a.size.xor(b.size);
    for ([x, y] in zipPairs(a.iterable, b.iterable)) {
        diff = diff.or((x.xor(y)).unsigned);
    }
    return diff == 0;
}

class Config(Toml toml) {
    shared Integer numIterations;
    numIterations = toml.getLong("numIterations", Long(10_000)).longValue();
}

entity {
    name = "User";
}
namedQueries {
    namedQuery {
        name=
            "findUserByName";
        query=
            "SELECT
                u
             FROM
                User u
             WHERE
                u.userName = :userName";
    }
}
shared class UserEntity {

    shared static User createUser(Context context) {
        assert (is AppContext context);
        
        value entity = UserEntity.withDefaults();
        context.entityManager.persist(entity);
        context.entityManager.flush();

        value user = entity.Active(context);
        user.init();
        return user;
    }

    id generatedValue { strategy=identity; }
    late Integer id;

    variable String userName = "";
    variable String email = "";
    variable Role role = Role.guest;
    variable Instant created = Instant.epoch;
    variable Instant modified = Instant.epoch;
    
    variable ByteArray passwordKey = createJavaByteArray {};
    variable ByteArray passwordSalt = createJavaByteArray {};
    variable Integer passwordIterations = 0;
    
    transient variable Anything()? onPreUpdate = null;

    new withDefaults() {
        
    }
    
    preUpdate
    shared void runPreUpdateCallback() {
        if (exists callback = onPreUpdate) {
            callback();
        }
    }
    
    shared class Active(Context ctx) {
        assert (is AppContext ctx);
        value config = Config(ctx.config);
        onPreUpdate = () {
            outer.modified = ctx.clock.instant();
        };

        shared UserEntity entity => outer;

        shared String userName => outer.userName;
        assign userName => outer.userName = userName;

        shared String email => outer.email;
        assign email => outer.email = email;

        shared Role role => outer.role;
        assign role => outer.role = role;
        
        shared Instant created => outer.created;

        shared Instant modified => outer.modified;
        
        shared void init() {
            outer.created = ctx.clock.instant();
        }
        
        shared void password(String password) {
            value random = SecureRandom();
            ByteArray salt = ByteArray(saltBytes, 0.byte);
            random.nextBytes(salt);
            value iterations = config.numIterations;
            value key = pbkdf2(password, salt, iterations);
            passwordKey = key;
            passwordSalt = salt;
            passwordIterations = iterations; 
        }

        shared Boolean hasPassword(String password) {
            value salt = passwordSalt;
            value iterations = passwordIterations;
            value key = pbkdf2(password, salt, iterations);
            return slowEquals(key, passwordKey); 
        }
        
        shared User(Context) loader() => makeLoader(
            `UserEntity`,
            UserEntity.Active,
            id
        );
        
        string =>
            "User(
                userName = ``userName``,
                email = ``email``,
                role = ``role``,
                created = ``created``,
                modified = ``modified``
             )";
    }
}

service (`interface ModelClassNameProvider`)
shared class UserEntityModelClassNameProvider()
        satisfies ModelClassNameProvider {
    shared actual String modelClassName => "fun.uschool.user.UserEntity";
}