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
import ceylon.interop.java {
    CeylonIterable
}

import com.google.common.base {
    MoreObjects {
        toStringHelper
    },
    Converter
}

import fun.uschool.course.api {
    PassiveCourse,
    Section,
    PassiveUserCourses,
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
import java.util {
    NavigableSet
}

import org.jsimpledb {
    JObject
}
import org.jsimpledb.annotation {
    jField__GETTER,
    jSimpleClass
}
import org.jsimpledb.util {
    ConvertedNavigableSet
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
        
        equals(Object that) => switch (that)
            case (is CourseImpl) that.objId == objId
            else false;
        
        hash => objId.hash;
    }
}

shared abstract class UserCoursesImpl() satisfies PassiveUserCourses & JObject {
    jField__GETTER { indexed = true; unique = true; }
    shared formal variable PassiveUser userField;
    jField__GETTER { indexed = true; }
    shared formal variable NavigableSet<CourseImpl> coursesField;
    
    shared actual class Active(Context ctx) extends super.Active(ctx) {
        passive => outer;
        
        shared actual User user => userField.Active(ctx);
        assign user => userField = user.passive;

        shared actual NavigableSet<Course> courses =>
                ConvertedNavigableSet(coursesField, CourseConverter(ctx));
        
        shared actual void addCourse(Course course) {
            assert (is CourseImpl impl = course.passive);
            coursesField.add(impl);
        }

        shared void init(User user) {
            assert (is JObject passiveUser = user.passive);
            userField = passiveUser;
        }

        string => toStringHelper("UserCourses")
            .add("objId", objId)
            .add("coursesField", coursesField)
            .add("userField", userField)
            .string;

        equals(Object that) => switch (that)
            case (is UserCoursesImpl) that.objId == objId
            else false;
        
        hash => objId.hash;
    }
}

service (`interface ModelClassProvider`)
shared class CourseImplModelClassProvider() satisfies ModelClassProvider {
    modelClass => `CourseImpl`;
}

service (`interface ModelClassProvider`)
shared class UserCoursesImplModelClassProvider() satisfies ModelClassProvider {
    modelClass => `UserCoursesImpl`;
}

shared class CourseConverter(Context ctx) extends Converter<Course, CourseImpl>() {
    shared actual Course doBackward(CourseImpl? a) {
        assert (exists a);
        return a.Active(ctx);
    }
    
    shared actual CourseImpl doForward(Course? a) {
        assert (exists a);
        assert (is CourseImpl result = a.passive);
        return result;
    }
}

shared class UserConverter(Context ctx) extends Converter<User, PassiveUser>() {
    shared actual User doBackward(PassiveUser? a) {
        assert (exists a);
        return a.Active(ctx);
    }
    
    shared actual PassiveUser doForward(User? a) {
        assert (exists a);
        return a.passive;
    }
}