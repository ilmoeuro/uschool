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
import ceylon.test {
    test
}

import java.util {
    Arrays {
        javaList = asList
    }
}



import org.jparsec {
    Parser,
    Parsers {
        eof=\iEOF,
        or
    },
    Scanners {
        isChar,
        literal=string_method
    }
}
import org.jparsec.pattern {
    CharPredicates {
        notAmong
    }
}

Parser<Title> title =
    literal(" ").many()
        .followedBy(literal("#"))
        .followedBy(literal(" ").many())
        .next(
            isChar(notAmong("\n")).many().source()
            .map((v) => Title(v.string)))
        .followedBy(or(literal("\n").many(), eof));

Parser<Paragraph> paragraph =
    literal(" ").many()
        .next(isChar(notAmong(" #\n")))
        .source()
        .next((h) =>
            or(
                isChar(notAmong("\n")),
                literal("\n").notFollowedBy(literal("\n")))
            .many()
            .source()
            .map((t) => Paragraph(h.string + t.string)))
        .followedBy(or(literal("\n").many(), eof));

Parser<out Section> section =
        or(title, paragraph);

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
shared void testMixedTitlesAndParagraphs() {
    value sample = "#this is title

                    this is paragraph
                    paragraph continues

                    
                    another paragraph
                    paragraph continues
                    
                    # this is another title
                    paragraph continues right after";
    value result = section.many().parse(sample);
    
    assert(result == javaList (
        Title("this is title"),
        Paragraph("this is paragraph\nparagraph continues"),
        Paragraph("another paragraph\nparagraph continues"),
        Title("this is another title"),
        Paragraph("paragraph continues right after")
    ));
}