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
import ceylon.language.meta.model {
    ClassOrInterface
}

import com.google.common.base {
    Converter
}

import fun.uschool.feature.impl {
    ContextImpl,
    ModelClassProvider,
    FieldTypeProvider
}
import fun.uschool.feature.api {
    Context
}
import fun.uschool.user.api {
    User,
    Role
}

import java.lang {
    ByteArray,
    JString=String
}
import java.security {
    SecureRandom
}

import javax.crypto {
    SecretKeyFactory
}
import javax.crypto.spec {
    PBEKeySpec
}

import org.jsimpledb.annotation {
    jField__GETTER,
    jSimpleClass
}
import org.jsimpledb.core {
    FieldType
}
import org.jsimpledb.core.type {
    StringEncodedType
}

Integer saltBytes = 32;
Integer keyLength = saltBytes * 8;
Integer initialNumIterations = 10_000;
String secretKeyAlgorithm = "PBKDF2WithHmacSHA256";

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
shared abstract class UserImpl() satisfies User {
    shared variable Context? context = null;

    jField__GETTER { indexed = true; }
    shared formal actual variable String userName;
    jField__GETTER
    shared formal actual variable String firstName;
    jField__GETTER
    shared formal actual variable String lastName;
    jField__GETTER
    shared formal actual variable Role role;

    jField__GETTER
    shared formal variable ByteArray passwordKey;
    jField__GETTER
    shared formal variable ByteArray passwordSalt;
    jField__GETTER
    shared formal variable Integer passwordIterations;
    
    shared actual void setPassword(String password) {
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
        "User should be activated before calling `init`"
        assert (is ContextImpl ctx = context);
        this.userName = "";
        this.firstName = "";
        this.lastName = "";
        this.role = Role.guest;
        this.passwordKey = createJavaByteArray{};
        this.passwordSalt = createJavaByteArray{};
        this.passwordIterations = 0;
    }
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

service (`interface ModelClassProvider`)
shared class UserImplModelClassProvider() satisfies ModelClassProvider {
    shared actual ClassOrInterface<Object> modelClass => `UserImpl`;
}

shared class RoleType() extends StringEncodedType<Role>(
    javaClass<Role>(),
    0,
    RoleConverter()
) {
}

service (`interface FieldTypeProvider`)
shared class RoleFieldTypeProvider() satisfies FieldTypeProvider {
    shared actual FieldType<out Object> fieldType => RoleType();
}