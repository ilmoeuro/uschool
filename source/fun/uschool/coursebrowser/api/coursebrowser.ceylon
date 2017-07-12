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
import fun.uschool.course.api {
    Course,
    listCourses,
    getUserCourses
}
import fun.uschool.feature.api {
    Context
}
import fun.uschool.user.api {
    User
}

import java.util {
    NavigableSet,
    JList=List
}
import java.util.stream {
    Collectors {
        toList
    }
}

import org.jsimpledb.util {
    NavigableSets {
        emptyNavigableSet=empty,
        difference
    }
}

Integer pageSize = 10;

shared class CourseBrowser(loadCurrentUser) {
    User?(Context) loadCurrentUser;
    
    shared class Active(Context ctx) {
        User? user = loadCurrentUser(ctx);

        NavigableSet<Course> allCourses;
        NavigableSet<Course> myCourses;
        NavigableSet<Course> availableCourses;
        
        allCourses = listCourses(ctx);
        if (exists user) {
            myCourses = getUserCourses(ctx, user).courses;
        } else {
            myCourses = emptyNavigableSet<Course>();
        }
        availableCourses = difference(allCourses, myCourses);
        
        shared variable Integer myCoursesPage = 0;
        shared variable Integer availableCoursesPage = 0;
        
        shared JList<Course> myCoursesList => myCourses
                .stream()
                .skip(myCoursesPage*pageSize)
                .limit(pageSize)
                .collect(toList<Course>());

        shared JList<Course> availableCoursesList => availableCourses
                .stream()
                .skip(availableCoursesPage*pageSize)
                .limit(pageSize)
                .collect(toList<Course>());
    }
}