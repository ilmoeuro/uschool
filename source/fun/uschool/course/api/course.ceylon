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
import fun.uschool.course.impl {
    CourseImpl,
    CourseConverter,
    UserCoursesImpl
}
import fun.uschool.feature.api {
    Context
}
import fun.uschool.feature.impl {
    AppContext,
    loader
}
import fun.uschool.user.api {
    User
}
import fun.uschool.user.impl {
    UserImpl
}

import java.io {
    File
}
import java.util {
    NavigableSet
}

import org.jsimpledb.util {
    ConvertedNavigableSet
}

shared interface Section of Title | Paragraph | Picture {
    shared formal String content;
}

shared class Title(content) satisfies Section {
    shared actual String content;
    
    string => "Title(``content``)";
    
    equals(Object that) => 
        if (is Title that)
            then content == that.content
            else false;
    
    hash => content.hash;
}

shared class Paragraph(content) satisfies Section {
    shared actual String content;
    
    string => "Paragraph(``content``)";

    equals(Object that) => 
        if (is Paragraph that)
            then content == that.content
            else false;
    
    hash => content.hash;
}

shared class Picture(identifier) satisfies Section {
    String identifier;
    shared actual String content = "";

    string => "Picture(``identifier``)";

    equals(Object that) => 
        if (is Picture that)
            then identifier == that.identifier
            else false;
    
    hash => identifier.hash;
}

shared interface PassiveCourse {
    shared formal class Active(Context ctx) {
        shared formal PassiveCourse passive;
        
        shared formal variable String title;
        shared formal variable String description;
        shared formal variable File? materialFolder;
        
        shared formal {Section*} sections;
    }
}

shared interface PassiveUserCourses {
    shared formal class Active(Context ctx) {
        shared formal PassiveUserCourses passive;

        shared formal User user;
        shared formal NavigableSet<Course> courses;
        shared formal void addCourse(Course course);
    }
}

shared alias Course => PassiveCourse.Active;
shared alias UserCourses => PassiveUserCourses.Active;

shared Course createCourse(Context ctx) {
    assert (is AppContext ctx);

    value tx = ctx.transaction;
    value passive = tx.create(`CourseImpl`);
    value result = passive.Active(ctx);
    result.init();
    return result;
}

shared Course(Context) courseLoader(Course course) =>
    loader(`CourseImpl`, PassiveCourse.Active, Course.passive, course);

shared NavigableSet<Course> listCourses(Context ctx) {
    assert (is AppContext ctx);
    
    value passives = ctx.transaction.getAll(`CourseImpl`);

    return ConvertedNavigableSet(passives, CourseConverter(ctx));
}

shared UserCourses getUserCourses(Context ctx, User user) {
    assert (is AppContext ctx);

    value tx = ctx.transaction;
    
    value ix = tx.queryIndex(`UserCoursesImpl`, "userField", `UserImpl`);
    value courseses = ix.asMap().get(user.passive);
    if (!courseses.empty) {
        return courseses.first().Active(ctx);
    } else {
        value result = tx.create(`UserCoursesImpl`).Active(ctx);
        result.init(user);
        return result;
    }
}

UserCourses(Context) userCoursesLoader(UserCourses course) =>
    loader(`UserCoursesImpl`, PassiveUserCourses.Active, UserCourses.passive, course);

