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
import fun.uschool.course {
    realCreateCourse=createCourse,
    realListCoursesPage=listCoursesPage,
    Course
}
import fun.uschool.feature.provider {
    ContextProvider
}
import fun.uschool.user {
    realCreateUser=createUser,
    realFindUserByName=findUserByName,
    User
}

import groovy.lang {
    Binding,
    GroovyShell
}

import java.io {
    BufferedReader,
    InputStreamReader
}
import java.lang {
    System
}
import java.time {
    Clock
}

shared class Api(provider) {
    ContextProvider provider;
    variable value ctx = provider.NewContext();
    
    shared User createUser() =>
            realCreateUser(ctx);

    shared User? findUserByName(String userName) =>
            realFindUserByName(ctx, userName);
    
    shared Course createCourse() =>
            realCreateCourse(ctx);
    
    shared {Course*} listCoursesPage(Integer pageNumber) =>
            realListCoursesPage(ctx, pageNumber, 10);

    shared void commit() {
        try {
            ctx.commit();
        } catch (Exception ex) {
            printError(ex);
        }
        ctx = provider.NewContext();
        
    }

    shared void rollback() {
        try {
            ctx.rollback();
        } catch (Exception ex) {
            // do nothing
        }
        ctx = provider.NewContext();
    }
}

String? readLine() {
    process.write("> ");
    process.flush();
    return process.readLine();
}

void printError(Exception ex) {
    process.writeError("ERROR: ");
    process.writeErrorLine(ex.message);
    value debug =  process.namedArgumentPresent("d")
                  || process.namedArgumentPresent("debug");
    if (debug) {
        ex.printStackTrace();
    }
}

shared void run() {
    value binding = Binding();
    value shell = GroovyShell(binding);
    value script =
            process.namedArgumentPresent("script")
            || process.namedArgumentPresent("s");
    value contextProvider = ContextProvider {
        subject = `class Api`;
        commit = true;
        clock = Clock.systemDefaultZone();
    };
    
    value api = Api(contextProvider);
    
    binding.setVariable("api", api);

    if (script) {
        try (value isr = InputStreamReader(System.\iin),
             value br = BufferedReader(isr)) {
            shell.evaluate(isr);
         } catch (Exception ex) {
            printError(ex);
         }
    } else {
        while (exists line = readLine()) {
            try {
                Object? result = shell.evaluate(line);
                if (exists result) {
                    print(result);
                }
            } catch (Exception ex) {
                printError(ex);
            }
        }
    }
    
    api.rollback();
}