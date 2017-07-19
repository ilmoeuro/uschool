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
    javaClass
}

import fun.uschool.course {
    CourseEntity,
    Exercise,
    Course
}
import fun.uschool.feature.api {
    Context,
    ModelClassNameProvider
}
import fun.uschool.feature.impl {
    AppContext,
    makeLoader
}
import fun.uschool.user {
    UserEntity,
    User
}

import java.time {
    Instant
}

import javax.persistence {
    id,
    generatedValue,
    entity,
    GenerationType {
        identity
    },
    manyToOne
}

shared alias Answer => AnswerEntity.Active;

shared Answer createAnswer(
    Context ctx,
    User user,
    Course course,
    Integer exerciseNumber,
    Exercise exercise,
    String correctAnswer,
    String answer
) {
    assert (is AppContext ctx);
    
    value passive = AnswerEntity {
        userEntity = user.entity;
        courseEntity = course.entity;
        exerciseNumber = exerciseNumber;
        exercise = exercise;
        correctAnswer = correctAnswer;
        answer = answer;
    };

    ctx.entityManager.persist(passive);
    value result = passive.Active(ctx);
    result.init();
    return result;
}

entity { name = "Answer"; }
shared sealed class AnswerEntity(
    manyToOne UserEntity userEntity,
    manyToOne CourseEntity courseEntity,
    Integer exerciseNumber,
    Exercise exercise,
    String correctAnswer,
    String answer
) {
    id generatedValue { strategy = identity; }
    late Integer id;
    variable Instant created = Instant.epoch;
    
    shared class Active(Context ctx) {
        assert (is AppContext ctx);

        shared AnswerEntity entity => outer;
        
        shared User user => userEntity.Active(ctx);
        shared Course course => courseEntity.Active(ctx);
        shared Integer exerciseNumber => outer.exerciseNumber;
        shared Exercise exercise => outer.exercise;
        shared String correctAnswer => outer.correctAnswer;
        shared String answer => outer.answer;
        
        shared void init() {
            created = ctx.clock.instant();
        }

        shared Answer(Context) loader() => makeLoader(
            `AnswerEntity`,
            AnswerEntity.Active,
            id
        );
    }
}

service (`interface ModelClassNameProvider`)
shared class AnswerEntityModelClassNameProvider()
        satisfies ModelClassNameProvider {
    shared actual String modelClassName =>
            javaClass<AnswerEntity>().canonicalName;
}