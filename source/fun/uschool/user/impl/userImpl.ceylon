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
    createJavaByteArray,
    javaString,
    javaClass
}

import com.google.common.base {
    Converter,
    MoreObjects {
        toStringHelper
    }
}
import com.moandjiezana.toml {
    Toml
}

import fun.uschool.feature.api {
    Context
}
import fun.uschool.feature.impl {
    AppContext,
    FieldTypeProvider,
    ModelClassProvider
}
import fun.uschool.user.api {
    PassiveUser,
    Role
}

import java.lang {
    ByteArray,
    JString=String
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

import org.jsimpledb {
    JObject
}
import org.jsimpledb.annotation {
    jField__GETTER,
    jSimpleClass,
    onChange
}
import org.jsimpledb.core.type {
    StringEncodedType
}

Integer saltBytes = 32;
Integer keyLength = saltBytes * 8;
Integer initialNumIterations = 10_000;
String secretKeyAlgorithm = "PBKDF2WithHmacSHA256";

shared class Config(Toml config) {
    
}

shared class RoleConverter() extends Converter<Role, JString>() {
    shared actual Role doBackward(JString? name) {
        "Cannot convert null to role."
        assert (exists name);
        return Role.ofName(name.string);
    }
    
    shared actual JString doForward(Role? role) {
        return javaString(role?.name else "null");
    }
}

shared class RoleType() extends StringEncodedType<Role>(
    javaClass<Role>(),
    0,
    RoleConverter()
) {
}

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

jSimpleClass
shared abstract class UserImpl() satisfies PassiveUser & JObject {
    jField__GETTER { indexed = true; unique = true; }
    shared formal variable String userNameField;
    jField__GETTER
    shared formal variable String firstNameField;
    jField__GETTER
    shared formal variable String lastNameField;
    jField__GETTER
    shared formal variable Role roleField;
    jField__GETTER
    shared formal variable Instant createdField;
    jField__GETTER
    shared formal variable Instant modifiedField;

    jField__GETTER
    shared formal variable ByteArray passwordKey;
    jField__GETTER
    shared formal variable ByteArray passwordSalt;
    jField__GETTER
    shared formal variable Integer passwordIterations;
    
    variable Anything()? onChanged = null;
    
    shared actual class Active(Context ctx) extends super.Active(ctx) {
        "Context should be AppContext, was `ctx`"
        assert (is AppContext ctx);
        
        onChanged = () => modifiedField = ctx.clock.instant();

        shared actual PassiveUser passive => outer;
        
        shared actual String userName => userNameField;
        assign userName => userNameField = userName;

        shared actual String firstName => firstNameField;
        assign firstName => firstNameField = firstName;

        shared actual String lastName => lastNameField;
        assign lastName => lastNameField = lastName;

        shared actual Role role => roleField;
        assign role => roleField = role;

        shared actual Instant created => createdField;
        shared actual Instant modified => modifiedField;

        shared actual void password(String password) {
            value random = SecureRandom();
            ByteArray salt = ByteArray(saltBytes, 0.byte);
            random.nextBytes(salt);
            value iterations = initialNumIterations;
            value key = pbkdf2(password, salt, iterations);
            passwordKey = key;
            passwordSalt = salt;
            passwordIterations = iterations;
        }
        
        shared actual Boolean hasPassword(String password) {
            value salt = passwordSalt;
            value iterations = passwordIterations;
            value key = pbkdf2(password, salt, iterations);
            return slowEquals(key, passwordKey);
        }

        shared void init() {
            userNameField = "";
            firstNameField = "";
            lastNameField = "";
            roleField = Role.guest;
            passwordKey = createJavaByteArray{};
            passwordSalt = createJavaByteArray{};
            passwordIterations = 0;
            createdField = ctx.clock.instant();
            modifiedField = this.created;
        }
        
        string => toStringHelper("User")
            .add("objId", objId)
            .add("userNameField", userNameField)
            .add("firstNameField", firstNameField)
            .add("lastNameField", lastNameField)
            .add("roleField", roleField)
            .add("createdField", createdField)
            .add("modifiedField", modifiedField)
            .add("passwordKey", passwordKey)
            .add("passwordSalt", passwordSalt)
            .add("passwordIterations", passwordIterations)
            .string;
    }
        
    onChange shared void changed() {
        if (exists handler = onChanged) {
            handler();
        }
    }
}

service (`interface FieldTypeProvider`)
shared class RoleFieldTypeProvider() satisfies FieldTypeProvider {
    fieldType => RoleType();
}

service (`interface ModelClassProvider`)
shared class UserImplModelClassProvider() satisfies ModelClassProvider {
    modelClass => `UserImpl`;
}