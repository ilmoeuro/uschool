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
    listCoursesPage,
    Course,
    countCourses
}
import fun.uschool.feature.api {
    Context
}
import fun.uschool.wicket {
    CompoundPanel
}

import java.util {
    JList=List,
    Arrays {
        jList=asList
    }
}

import org.apache.wicket.markup.html.basic {
    Label
}
import org.apache.wicket.markup.html.form {
    DropDownChoice
}
import org.apache.wicket.markup.html.list {
    PropertyListView,
    ListItem
}
import org.apache.wicket.model {
    PropertyModel
}

shared class Page(index) {
    shared Integer index;
    shared Integer number = index + 1;

    string =>
            "Page #``number``";
    equals(Object other) =>
            if (is Page other) then index == other.index else false;
    hash =>
            index.hash;
}

shared class PassiveCourseList() {
    variable Integer pageNumber = 0;
    Integer pageSize = 10;
    
    shared class Active(Context ctx) {
        shared {Course*} courses =>
            listCoursesPage(ctx, outer.pageNumber, pageSize);
        
        shared Integer numPages =>
            let (count = countCourses(ctx))
                if (count == 0)
                    then 1
                else if (pageSize.divides(count))
                    then count/pageSize
                else count/pageSize + 1;
        
        shared JList<Course> coursesList =>
            jList(*courses);
        
        shared Page page => Page(pageNumber);
        assign page => pageNumber = page.index;
        
        shared JList<Page> pagesList =>
            jList (for (i in 0:numPages) Page(i));
    }
}

shared alias CourseList => PassiveCourseList.Active;

shared class CourseListPanel(id) extends CompoundPanel<CourseList>(id) {
    String id;
    
    object page extends DropDownChoice<Page>("page") {
        wantOnSelectionChangedNotifications() => true;
    }
    
    object coursesList extends PropertyListView<Course>("coursesList") {
        shared actual void populateItem(ListItem<Course> item) {
            object title extends Label("title") {
                
            }
            object description extends Label("description") {
                
            }

            item.add(title);
            item.add(description);
        }
    }
    
    shared actual void onInitialize() {
        super.onInitialize();
        page.setChoices(PropertyModel(model, "pagesList"));
        add(page);
        add(coursesList);
    }
}