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
    LessResource
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
import org.apache.wicket.request.resource {
    ResourceReference
}

shared abstract class BasePage<ModelType>(model) extends WebPage(model)
        given ModelType satisfies Object {
    shared IModel<ModelType> model;
    shared ModelType modelObject => model.\iobject;

    object pureTheme extends ResourceReference(
        `BasePage<Object>`,
        "pure-theme-uschool.less"
    ) {
        resource = LessResource(`module`, "pure-theme-uschool.less");
    }

    object basePageLess extends ResourceReference(
        `BasePage<Object>`,
        "BasePage.less"
    ) {
        resource = LessResource(`module`, "BasePage.less");
    }

    value pure =
        WebjarsCssResourceReference("purecss/1.0.0/build/pure-min.css");
    
    shared actual void renderHead(IHeaderResponse response) {
        super.renderHead(response);
        response.render(CssHeaderItem.forReference(pure));
        response.render(CssHeaderItem.forReference(pureTheme));
        response.render(CssHeaderItem.forReference(basePageLess));
    }
}