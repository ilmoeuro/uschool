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
    javaClassFromInstance
}
import ceylon.test {
    beforeTest,
    afterTest
}

import java.lang {
    ClassLoader,
    Thread
}
shared class SetupContextClassLoader(ClassLoader classLoader)
        satisfies Destroyable {
    value thread = Thread.currentThread();
    value originalClassLoader = thread.contextClassLoader;
    thread.contextClassLoader = classLoader;
    
    shared actual void destroy(Throwable? error) {
        thread.contextClassLoader = originalClassLoader;
    }
}

shared abstract class Test() {
    variable SetupContextClassLoader? setupContextClassLoader = null;
    
	beforeTest
	shared void setupClassLoader() {
        value classLoader = javaClassFromInstance(this).classLoader;
        setupContextClassLoader = SetupContextClassLoader(classLoader);
	}
	
	afterTest
	shared void restoreClassLoader() {
		if (exists sccl = setupContextClassLoader) {
			sccl.destroy(null);
			setupContextClassLoader = null;
		}
	}
}