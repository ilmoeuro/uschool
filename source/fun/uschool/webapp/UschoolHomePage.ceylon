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
import fun.uschool.courselist {
    CourseListPanel,
    CourseList,
    PassiveCourseList
}
import org.apache.wicket.model {
    CompoundPropertyModel
}
import org.apache.wicket.markup.head {
    IHeaderResponse,
    CssHeaderItem
}
import de.agilecoders.wicket.webjars.request.resource {
    WebjarsCssResourceReference
}
import org.apache.wicket.markup.html {
    WebPage
}
import fun.uschool.feature.api {
    Context
}

shared class HomePageModel() {
    value courseList = PassiveCourseList();
    
    shared class Active(Context ctx) {

        shared CourseList courseList =
            outer.courseList.Active(ctx);

    }
}

shared class UschoolHomePage() extends WebPage(
    CompoundPropertyModel(
        ContextProvidingModel(
            HomePageModel().Active
        )
    )
) {
    object courseList extends CourseListPanel("courseList") {
    }
    
    shared actual void renderHead(IHeaderResponse response) {
        value pure = WebjarsCssResourceReference("purecss/1.0.0/build/pure-min.css");
        response.render(CssHeaderItem.forReference(pure));
    }
    
    shared actual void onInitialize() {
        super.onInitialize();
        add(courseList);
    }
}