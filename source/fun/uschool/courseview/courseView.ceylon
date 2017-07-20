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
    Course,
    Section,
    Heading,
    Paragraph,
    Picture,
    MultiSelectExercise,
    ExerciseField,
    Correctness {
        correct
    }
}
import fun.uschool.feature.api {
    Context
}
import fun.uschool.util {
    cast,
    nullSafe
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

import org.apache.wicket.markup.html {
    WebMarkupContainer
}
import org.apache.wicket.markup.html.basic {
    Label
}
import org.apache.wicket.markup.html.form {
    CheckBox
}
import org.apache.wicket.markup.html.image {
    ExternalImage
}
import org.apache.wicket.markup.html.list {
    PropertyListView,
    ListItem,
    ListView
}
import org.apache.wicket.model {
    IModel
}

shared class ExerciseFieldWrapper(ExerciseField ef) {
    shared String choice => ef.choice;
    shared Boolean correctness => ef.correctness == correct;
}

shared class MultiSelectExerciseWrapper(MultiSelectExercise mse) {
    shared {ExerciseFieldWrapper*} choices =>
        mse.choices.map(ExerciseFieldWrapper);
    shared JList<ExerciseFieldWrapper> choicesList =>
        jList(*choices);
}

shared class SectionWrapper(Section section) {
    shared Heading? heading =>
        cast<Heading>(section);
    shared Paragraph? paragraph =>
        cast<Paragraph>(section);
    shared Picture? picture =>
        cast<Picture>(section);
    shared MultiSelectExerciseWrapper? multiSelectExercise =>
        nullSafe(MultiSelectExerciseWrapper)(
            cast<MultiSelectExercise>(section));
}

shared class PassiveCourseView(loadCourse) {
    Course(Context) loadCourse;
    
    shared class Active(Context context) {
        Course course = loadCourse(context);
        
        shared String title =>
            course.title;
        shared String description =>
            course.description;
        shared {SectionWrapper*} sections =>
            course.sections.map(SectionWrapper);
        shared JList<SectionWrapper> sectionsList =>
            jList(*sections);
    }
}

shared alias CourseView => PassiveCourseView.Active;

shared class SectionWrapperPanel(id, model)
        extends CompoundPanel<SectionWrapper>.withModel(id, model) {
    String id;
    IModel<SectionWrapper> model;


    value heading = WebMarkupContainer("heading");
    value paragraph = WebMarkupContainer("paragraph");
    value picture = WebMarkupContainer("picture");
    value multiSelectExercise = WebMarkupContainer("multiSelectExercise");

    shared actual void onInitialize() {
        super.onInitialize();

        value headingContent = Label("heading.content");
        value paragraphContent = Label("paragraph.content");
        value pictureSource = ExternalImage("picture.source");
        
        object multiSelectExerciseChoices
                extends PropertyListView<ExerciseFieldWrapper>(
            "multiSelectExercise.choicesList") {
            shared actual void populateItem(
                ListItem<ExerciseFieldWrapper> item) {
                object correctness extends CheckBox("correctness") {
                    enabled => false;
                }
                value choice = Label("choice");
                item.add(correctness);
                item.add(choice);
            }
        }

        heading.add(headingContent);
        paragraph.add(paragraphContent);
        picture.add(pictureSource);
        multiSelectExercise.add(multiSelectExerciseChoices);
        
        add(heading);
        add(paragraph);
        add(picture);
        add(multiSelectExercise);
    }
    
    shared actual void onConfigure() {
        super.onConfigure();
        
        value wrapper = modelObject;
        heading.setVisible(wrapper.heading exists);
        paragraph.setVisible(wrapper.paragraph exists);
        picture.setVisible(wrapper.picture exists);
        multiSelectExercise.setVisible(wrapper.multiSelectExercise exists);
    }
}

shared class CourseViewPanel(id) extends CompoundPanel<CourseView>(id) {
    String id;
    
    shared actual void onInitialize() {
        super.onInitialize();
        
        value title = Label("title");
        value description = Label("description");
        object sectionsList extends ListView<SectionWrapper>("sectionsList") {
            shared actual void populateItem(ListItem<SectionWrapper> item) {
                value sectionWrapperPanel =
                    SectionWrapperPanel("sectionWrapper", item.model);
                item.add(sectionWrapperPanel);
            }
        }

        add(title);
        add(description);
        add(sectionsList);
    }
}
