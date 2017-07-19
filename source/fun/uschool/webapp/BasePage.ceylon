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
import de.agilecoders.wicket.webjars.request.resource {
    WebjarsCssResourceReference
}

import fun.uschool.wicket {
    LessResourceReference
}

import org.apache.wicket.markup.head {
    IHeaderResponse,
    CssHeaderItem
}
import org.apache.wicket.markup.html {
    WebPage
}
import org.apache.wicket.model {
    IModel
}

shared abstract class BasePage<ModelType>(model) extends WebPage(model)
        given ModelType satisfies Object {
    shared IModel<ModelType> model;
    shared ModelType modelObject => model.\iobject;

    value pure =
        WebjarsCssResourceReference("purecss/1.0.0/build/pure-min.css");

    value pureTheme =
        LessResourceReference(`class`, "pure-theme-uschool.less");

    value basePageStyle =
        LessResourceReference(`class`, "BasePage.less");
    
    shared actual void renderHead(IHeaderResponse response) {
        super.renderHead(response);
        response.render(CssHeaderItem.forReference(pure));
        response.render(CssHeaderItem.forReference(pureTheme));
        response.render(CssHeaderItem.forReference(basePageStyle));
    }
}