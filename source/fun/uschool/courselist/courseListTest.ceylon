import ceylon.test {
    test,
    parameters
}

import fun.uschool.course {
    createCourse,
    Course
}
import fun.uschool.feature.provider {
    ContextProvider
}
import fun.uschool.util {
    Test
}
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

{[Integer, Integer]*} numPagesParameters = {
    [0, 1],
    [9, 1],
    [10, 1],
    [11, 2],
    [19, 2],
    [20, 2],
    [21, 3]
};

{[Integer, {String*}]*} pageNumberParameters = {
    [-1, {}],
    [0, {for (i in 0:10) "Course #``i``"}],
    [1, {for (i in 10:10) "Course #``i``"}],
    [2, {}]
};

class UserTest() extends Test() {
    function provider() => ContextProvider(
        `class`
    );
	
	test
	parameters(`value numPagesParameters`)
	shared void testNumPages(Integer numCourses, Integer expectedNumPages) {
		try (ctx = provider().NewContext()) {
            for (i in 0:numCourses) {
                createCourse(ctx);
            }
            
            value courseList = CourseList().Active(ctx);
            
            assert (courseList.numPages == expectedNumPages);
		}
	}

	test
	parameters(`value pageNumberParameters`)
	shared void testPageNumber(
		Integer pageNumber,
		{String*} expectedCourseTitles
	) {
		try (ctx = provider().NewContext()) {
            for (i in 0:20) {
                value course = createCourse(ctx);
                course.title = "Course #``i``";
            }
            
            value courseList = CourseList().Active(ctx);
            courseList.pageNumber = pageNumber;
            value actualCourseTitles = courseList.courses.map(Course.title);
            assert ([*actualCourseTitles] == [*expectedCourseTitles]);
		}
	}
}