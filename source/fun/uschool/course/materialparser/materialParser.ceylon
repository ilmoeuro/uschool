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
    CeylonList
}
import ceylon.test {
    test
}

import fun.uschool.course {
    Title,
    Section,
    ExerciseField,
    Picture,
    Paragraph,
    MultiSelectExercise,
    Correctness {
        correct,
        incorrect
    }
}

import java.lang {
    Void
}

import org.jparsec {
    Parser,
    Parsers {
        or
    },
    Scanners {
        isChar,
        literal=string_method
    }
}
import org.jparsec.pattern {
    CharPredicates {
        among,
        notAmong,
        isAlphaNumeric
    }
}

shared Parser<Void> emptyLine =
        literal(" ").skipMany().followedBy(literal("\n"));

shared Parser<Title> title =
    literal(" ").many()
        .followedBy(literal("#"))
        .followedBy(literal(" ").many())
        .next(
            isChar(notAmong("\n")).many().source()
            .map((v) => Title(v.string)))
        .followedBy(emptyLine.many());

// TODO handle empty lines in paragraphs
shared Parser<Paragraph> paragraph =
    literal(" ").many()
    .next(isChar(isAlphaNumeric))
    .next(
        or(
            isChar(notAmong("\n")),
            literal("\n").notFollowedBy(literal("\n")))
        .many())
    .source()
    .map((s) => Paragraph(s.string))
    .followedBy(literal("\n").many());

shared Parser<Picture> picture =
    literal(" ").many()
        .followedBy(literal("*"))
        .followedBy(literal(" ").many())
        .followedBy(literal("picture:"))
        .followedBy(literal(" ").many())
        .next(
            isChar(notAmong(" \n")).many().source()
            .map((v) => Picture(v.string)))
        .followedBy(literal(" ").many())
        .followedBy(emptyLine.many());

shared Parser<ExerciseField> multiSelectField =
    literal(" ").many()
        .followedBy(literal("["))
        .next(
            or(
                isChar(among("*x")).map((_) => correct),
                literal(" ").map((_) => incorrect)))
        .followedBy(literal("]"))
        .followedBy(literal(" ").many())
        .next((correct) =>
            isChar(notAmong("\n")).many().source()
            .map((choice) => ExerciseField(choice.string, correct)))
        .followedBy(emptyLine.many());
        
shared Parser<MultiSelectExercise> multiSelectExercise =
    multiSelectField
        .many()
        .followedBy(emptyLine.many())
        .map((fields) => MultiSelectExercise(CeylonList(fields)));

shared Parser<out Section> section =
        or(title, paragraph, picture, multiSelectExercise);

test
shared void testTitleWithoutWhitespace() {
    value input = "#title";
    value expected = Title("title");
    value actual = title.parse(input);
    assert (actual == expected);
}

test
shared void testTitleWithWhitespace() {
    value input = "  # title";
    value expected = Title("title");
    value actual = title.parse(input);
    assert (actual == expected);
}

test
shared void testPictureWithoutWhitespace() {
    value input = "*picture:picture";
    value expected = Picture("picture");
    value actual = picture.parse(input);
    assert (actual == expected);
}

test
shared void testPictureWithWhitespace() {
    value input = "  * picture:  picture";
    value expected = Picture("picture");
    value actual = picture.parse(input);
    assert (actual == expected);
}

test
shared void testParagraphWithoutNumberSign() {
    value input = "paragraph";
    value expected = Paragraph("paragraph");
    value actual = paragraph.parse(input);
    assert (actual == expected);
}

test
shared void testParagraphWithNumberSign() {
    value input = "paragraph#";
    value expected = Paragraph("paragraph#");
    value actual = paragraph.parse(input);
    assert (actual == expected);
}

test
shared void testCombination() {
    value sample = "#this is title

                    this is paragraph
                    paragraph continues


                    another paragraph
                    paragraph continues

                    *picture: picId

                    # this is another title
                    paragraph continues right after

                    [ ] incorrect field
                    [x] correct field
                    [ ] another incorrect field

                    yet another paragraph

                    [*] correct field";
    value actual = CeylonList(section.many().parse(sample));
    
    value expected = {
        Title("this is title"),
        Paragraph("this is paragraph\nparagraph continues"),
        Paragraph("another paragraph\nparagraph continues"),
        Picture("picId"),
        Title("this is another title"),
        Paragraph("paragraph continues right after"),
        MultiSelectExercise {
            ExerciseField("incorrect field", incorrect),
            ExerciseField("correct field", correct),
            ExerciseField("another incorrect field", incorrect)
        },
        Paragraph("yet another paragraph"),
        MultiSelectExercise {
            ExerciseField("correct field", correct)
        }
    };
    
    assert ([*actual] == [*expected]);
}