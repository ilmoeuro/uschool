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
import com.google.common.base {
    MoreObjects {
        toStringHelper
    }
}

import fun.uschool.course.api {
    PassiveCourse,
    Section,
    PassiveAttendance,
    Course
}
import fun.uschool.feature.api {
    Context
}
import fun.uschool.feature.impl {
    ModelClassProvider
}
import fun.uschool.user.api {
    PassiveUser,
    User
}

import java.io {
    File,
    FileReader
}

import org.jsimpledb {
    JObject
}
import org.jsimpledb.annotation {
    jField__GETTER,
    jSimpleClass,
    jCompositeIndex
}

import ceylon.interop.java {
    CeylonIterable
}

String materialFileName = "material.txt";

jSimpleClass
shared abstract class CourseImpl() satisfies PassiveCourse & JObject {

    jField__GETTER
    shared formal variable String titleField;
    jField__GETTER
    shared formal variable String descriptionField;
    jField__GETTER
    shared formal variable File? materialFolderField;
    
    shared actual class Active(Context ctx) extends super.Active(ctx) {
        passive => outer;
        
        shared actual String title => titleField;
        assign title => titleField = title;
        
        shared actual String description => descriptionField;
        assign description => descriptionField = description;
        
        shared actual File? materialFolder => materialFolderField;
        assign materialFolder => materialFolderField = materialFolder;
        
        shared actual {Section*} sections {
            if (exists mf = materialFolderField) {
                value materialFile = File(mf, materialFileName);
                try (reader = FileReader(materialFile)) {
                    return CeylonIterable(section.many().parse(reader));
                }
            }
            return {};
        }
        
        shared void init() {
            titleField = "";
            descriptionField = "";
            materialFolder = null;
        }
        
        string => toStringHelper("Course")
            .add("objId", objId)
            .add("titleField", titleField)
            .add("descriptionField", descriptionField)
            .add("materialFolderField", materialFolderField)
            .string;
    }
}

jSimpleClass {
    compositeIndexes = {
        jCompositeIndex {
            name = "byCourseAndUser";
            fields = {"courseField", "userField"};
        }
    };
}
shared abstract class AttendanceImpl() satisfies PassiveAttendance & JObject {
    jField__GETTER
    shared formal variable PassiveCourse courseField;
    jField__GETTER
    shared formal variable PassiveUser userField;
    jField__GETTER { unique = true; indexed = true; }
    shared formal variable String uniqueKey;
    
    shared actual class Active(Context ctx) extends super.Active(ctx) {
        passive => outer;
        
        shared actual Course course => courseField.Active(ctx);
        assign course => courseField = course.passive;
        
        shared actual User user => userField.Active(ctx);
        assign user => userField = user.passive;
        
        shared void init(Course course, User user) {
            assert (is JObject passiveCourse = course.passive);
            assert (is JObject passiveUser = user.passive);
            value courseId = passiveCourse.objId.asLong();
            value userId = passiveUser.objId.asLong();
            courseField = passiveCourse;
            userField = passiveUser;
            uniqueKey = "``courseId``,``userId``";
        }

        string => toStringHelper("Attendance")
            .add("objId", objId)
            .add("courseField", courseField)
            .add("userField", userField)
            .add("uniqueKey", uniqueKey)
            .string;
    }
}

service (`interface ModelClassProvider`)
shared class CourseImplModelClassProvider() satisfies ModelClassProvider {
    modelClass => `CourseImpl`;
}

service (`interface ModelClassProvider`)
shared class AttendanceImplModelClassProvider() satisfies ModelClassProvider {
    modelClass => `AttendanceImpl`;
}