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
    Course
}
import fun.uschool.courselist {
    CourseListPanel,
    CourseList,
    PassiveCourseList
}
import fun.uschool.courseview {
    PassiveCourseView,
    CourseView,
    CourseViewPanel
}
import fun.uschool.feature.api {
    Context
}

import org.apache.wicket.model {
    CompoundPropertyModel
}

shared class CoursePageModel(loadCourse) {
    Course(Context) loadCourse;

    value courseView = PassiveCourseView(loadCourse);
    
    shared class Active(Context ctx) {
        shared CourseView courseView = outer.courseView.Active(ctx);
    }
}

shared class HomePageModel() {
    value courseList = PassiveCourseList();
    
    shared class Active(Context ctx) {

        shared CourseList courseList = outer.courseList.Active(ctx);

    }
}

shared class CoursePage(loadCourse) extends BasePage<CoursePageModel.Active>(
    CompoundPropertyModel(
        ContextProvidingModel(
            CoursePageModel(loadCourse).Active
        )
    )
) {
    Course(Context) loadCourse;
    
    shared actual void onInitialize() {
        super.onInitialize();

        object courseView extends CourseViewPanel("courseView") {
        }

        add(courseView);
    }
}

shared class HomePage() extends BasePage<HomePageModel.Active>(
    CompoundPropertyModel(
        ContextProvidingModel(
            HomePageModel().Active
        )
    )
) {
    shared actual void onInitialize() {
        super.onInitialize();

        object courseList extends CourseListPanel("courseList") {
            onCourseSelected(Course(Context) loadCourse) =>
                    setResponsePage(CoursePage(loadCourse));
        }

        add(courseList);
    }
}