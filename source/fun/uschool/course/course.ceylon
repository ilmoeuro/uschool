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
import fun.uschool.feature.api {
    Context,
    ModelClassNameProvider
}
import fun.uschool.feature.impl {
    makeLoader,
    AppContext
}

import java.io {
    File
}
import java.time {
    Instant
}

import javax.persistence {
    id,
    generatedValue,
    GenerationType {
        identity
    },
    transient,
    preUpdate,
    entity,
    namedQueries,
    namedQuery
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

shared alias Course => CourseEntity.Active;

shared {Course*} listCoursesPage(
    Context ctx,
    Integer pageNum,
    Integer pageSize
) {
    assert (is AppContext ctx);
    
    value query = ctx.entityManager.createNamedTypedQuery(
        "listAll",
        `CourseEntity`);
    query.setFirstResult(pageNum*pageSize);
    query.setMaxResults(pageSize);
    value results = query.getResults();
    return results.map((c) => c.Active(ctx));
}

entity {
    name = "Course";
}
namedQueries {
    namedQuery {
        name=
            "listAll";
        query=
            "SELECT
                c
             FROM
                Course c";
    }
}
shared class CourseEntity {

    shared static Course createCourse(Context context) {
        assert (is AppContext context);
        
        value entity = CourseEntity.withDefaults();
        context.entityManager.persist(entity);
        context.entityManager.flush();

        value course = entity.Active(context);
        course.init();
        return course;
    }
    
    id generatedValue { strategy = identity; }
    late Integer id;

    variable String description = "";
    variable File? materialFolder = null;
    variable String title = "";
    variable Instant created = Instant.epoch;
    variable Instant modified = Instant.epoch;
    
    transient variable Anything()? onPreUpdate = null;

    new withDefaults() {
        
    }

    preUpdate
    shared void runPreUpdateCallback() {
        if (exists callback = onPreUpdate) {
            callback();
        }
    }

    shared class Active(Context ctx) {
        assert (is AppContext ctx);

        onPreUpdate = () {
            outer.modified = ctx.clock.instant();
        };

        shared CourseEntity entity => outer;

        shared String title => outer.title;
        assign title => outer.title = title;

        shared String description => outer.description;
        assign description => outer.description = description;

        shared File? materialFolder => outer.materialFolder;
        assign materialFolder => outer.materialFolder = materialFolder;

        shared {Section*} sections => {};

        shared Course(Context) loader() => makeLoader(
            `CourseEntity`,
            CourseEntity.Active,
            id
        );
        
        shared void init() {
            outer.created = ctx.clock.instant();
        }

        string =>
            "Course(
                title = ``title``,
                description = ``description``,
                materialFolder = ``materialFolder else "<null>"``,
             )";
    }
}

service (`interface ModelClassNameProvider`)
shared class CourseEntityModelClassNameProvider()
        satisfies ModelClassNameProvider {
    shared actual String modelClassName => "fun.uschool.course.CourseEntity";
}