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
    javaString
}

import de.agilecoders.wicket.webjars.request.resource {
    WebjarsCssResourceReference
}

import fun.uschool.wicket {
    LessResourceReference
}

import java.lang {
    JString=String
}

import org.apache.wicket.authroles.authentication.panel {
    SignInPanel
}
import org.apache.wicket.markup.head {
    IHeaderResponse,
    CssHeaderItem
}
import org.apache.wicket.markup.html {
    WebPage,
    WebMarkupContainer
}
import org.apache.wicket.markup.html.basic {
    Label
}
import org.apache.wicket.markup.html.form {
    Form
}
import org.apache.wicket.model {
    IModel,
    Model
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
    
    value loginWidget = WebMarkupContainer("loginWidget");
    value loggedInWidget = WebMarkupContainer("loggedInWidget");
    
    shared actual default void onInitialize() {
        super.onInitialize();

        value signInPanel = SignInPanel("signInPanel");
        loginWidget.add(signInPanel);
        add(loginWidget);
        
        object loggedInPersonModel extends Model<JString>() {
            shared actual JString \iobject => javaString(sess.currentUserName);
            assign \iobject {}
        }
        value loggedInPerson = Label("loggedInPerson", loggedInPersonModel);
        loggedInWidget.add(loggedInPerson);
        object logoutForm extends Form<Object>("logoutForm") {
            shared actual void onSubmit() {
                sess.invalidate();
            }
        }
        loggedInWidget.add(logoutForm);
        add(loggedInWidget);
    }
    
    shared actual default void onConfigure() {
        super.onConfigure();
        
        loginWidget.setVisible(!sess.signedIn);
        loggedInWidget.setVisible(sess.signedIn);
    }
    
    shared actual default void renderHead(IHeaderResponse response) {
        super.renderHead(response);

        response.render(CssHeaderItem.forReference(pure));
        response.render(CssHeaderItem.forReference(pureTheme));
        response.render(CssHeaderItem.forReference(basePageStyle));
    }
}