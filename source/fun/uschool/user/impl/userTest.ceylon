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
    javaClassFromInstance,
    createJavaByteArray
}
import ceylon.test {
    beforeTest,
    afterTest,
    test,
    parameters
}

import fun.uschool.feature.impl {
    withTestContext,
    TestContextProvider
}
import fun.uschool.feature.api {
    Context
}
import fun.uschool.user.api {
    Role,
    createUser,
    User,
    userLoader
}

import java.lang {
    ClassLoader,
    Thread,
    ByteArray
}

{[ByteArray, ByteArray, Boolean]*} slowEqualsTestCases => {
    [
      createJavaByteArray {},
      createJavaByteArray {},
      true
    ], [
      createJavaByteArray {0.byte},
      createJavaByteArray {},
      false
    ], [
      createJavaByteArray {},
      createJavaByteArray {0.byte},
      false
    ], [
      createJavaByteArray (0.byte .. 127.byte),
      createJavaByteArray {},
      false
    ], [
      createJavaByteArray (0.byte .. 127.byte),
      createJavaByteArray (0.byte .. 127.byte),
      true
    ]
};

{[String]*} positivePasswordTestCases => {
    [""],
    ["\{#0000}"],
    ["password"],
    ["1234567890"],
    [String('a'..'z')],
    [String('\{#0100}'..'\{#01FF}')]
};

{[String, String]*} negativePasswordTestCases => {
    ["", " "],
    ["\{#0000}", "\{#0001}"],
    ["password", "password1"],
    ["1234567890", "0987654321"],
    [String('a'..'z'), String('a'..'y')],
    [String('\{#0100}'..'\{#01FF}'), ""]
};

class UserTest() {
    variable ClassLoader? originalClassLoader = null;
    
	beforeTest
	shared void setupClassLoader() {
		value thread = Thread.currentThread();
		originalClassLoader = thread.contextClassLoader;
		thread.contextClassLoader = javaClassFromInstance(this).classLoader;
	}
	
	afterTest
	shared void restoreClassLoader() {
		if (exists cl = originalClassLoader) {
			Thread.currentThread().contextClassLoader = cl;
		}
	}
	
	test
	shared void testCreateUser() {
		withTestContext(`module`, (ctx) {
			value user = createUser(ctx);
			user.userName = "userName";
			user.firstName = "firstName";
			user.lastName = "lastName";
			user.role = Role.guest;
			assert (user.userName == "userName");
			assert (user.firstName == "firstName");
			assert (user.lastName == "lastName");
			assert (user.role == Role.guest);
		});
	}

	test
	parameters (`value positivePasswordTestCases`)
	shared void testPasswordPositive(String password) {
		withTestContext(`module`, (ctx) {
			value user = createUser(ctx);
			user.setPassword(password);
			assert(user.hasPassword(password));
		});
	}

	test
	parameters (`value negativePasswordTestCases`)
	shared void testPasswordNegative(String password1, String password2) {
		withTestContext(`module`, (ctx) {
			value user = createUser(ctx);
			user.setPassword(password1);
			assert(!user.hasPassword(password2));
		});
	}

    test
    shared void testUserLoader() {
        value provider = TestContextProvider {
            commit = true;
            subject = `module`;
        };
		variable User(Context)? loadUser = null;
		provider.withContext((ctx) {
			value user = createUser(ctx);
			user.userName = "userName";
			user.firstName = "firstName";
			user.lastName = "lastName";
			user.role = Role.guest;
			loadUser = userLoader(user);
        });
        provider.withContext((ctx) {
            assert (exists loadUser_ = loadUser);
            value user = loadUser_(ctx);
			assert (user.userName == "userName");
			assert (user.firstName == "firstName");
			assert (user.lastName == "lastName");
			assert (user.role == Role.guest);
        });
	}
	
	test
	parameters(`value slowEqualsTestCases`)
	shared void testSlowEquals(
		ByteArray value1,
		ByteArray value2,
		Boolean shouldEqual
	) {
		assert(slowEquals(value1, value2) == shouldEqual);
	}
}