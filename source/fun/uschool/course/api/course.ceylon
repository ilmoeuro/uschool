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
    AttendanceImpl
}
import fun.uschool.feature.api {
    Context
}
import fun.uschool.feature.impl {
    AppContext,
    loader
}
import fun.uschool.user.api {
    User,
    PassiveUser
}

import java.io {
    File
}

import org.jsimpledb.tuple {
    Tuple2
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

shared interface PassiveAttendance {
    shared formal class Active(Context ctx) {
        shared formal PassiveAttendance passive;

        shared formal Course course;
        shared formal User user;
    }
}

shared alias Course => PassiveCourse.Active;
shared alias Attendance => PassiveAttendance.Active;

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

shared {Course*} listCourses(Context ctx) {
    assert (is AppContext ctx);
    
    value tx = ctx.transaction;
    return {for (course in tx.getAll(`CourseImpl`)) course.Active(ctx)};
}

shared Attendance createAttendance(Context ctx, Course course, User user) {
    assert (is AppContext ctx);

    value tx = ctx.transaction;
    value result = tx.create(`AttendanceImpl`).Active(ctx);
    result.init(course, user);
    return result;
}

shared Attendance? findAttendance(Context ctx, Course course, User user) {
    assert (is AppContext ctx);
    
    value tx = ctx.transaction;
    value ix = tx.queryCompositeIndex(
        `AttendanceImpl`,
        "byCourseAndUser",
        `PassiveCourse`,
        `PassiveUser`);
    value attendances = ix.asMap().get(Tuple2(course, user));
    if (!attendances.empty) {
        return attendances.first().Active(ctx);
    } else {
        return null;
    }
}

Attendance(Context) attendanceLoader(Attendance course) =>
    loader(`AttendanceImpl`, PassiveAttendance.Active, Attendance.passive, course);