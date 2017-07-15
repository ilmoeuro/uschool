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
import java.util {
    JList = List,
    Arrays {
        jList = asList
    }
}
import fun.uschool.course {
    listCoursesPage,
    Course,
    countCourses
}
import fun.uschool.feature.api {
    Context
}
shared class CourseList() {
    variable Integer pageNumber = 0;
    Integer pageSize = 10;
    
    shared class Active(Context ctx) {
        shared {Course*} courses =>
            listCoursesPage(ctx, outer.pageNumber, pageSize);
        
        shared JList<Course> coursesList =>
            jList(*courses);
        
        shared Integer numPages =>
            let (count = countCourses(ctx))
                if (count == 0)
                    then 1
                else if (pageSize.divides(count))
                    then count/pageSize
                else count/pageSize + 1;
        
        shared Integer pageNumber => outer.pageNumber;
        assign pageNumber => outer.pageNumber = pageNumber;
    }
}
