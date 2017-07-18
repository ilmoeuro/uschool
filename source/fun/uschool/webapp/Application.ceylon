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

import de.agilecoders.wicket.webjars {
    WicketWebjars
}
import de.agilecoders.wicket.webjars.settings {
    WebjarsSettings
}

import fun.uschool.course {
    createCourse
}
import fun.uschool.feature.provider {
    ContextProvider
}
import fun.uschool.user {
    createUser
}
import fun.uschool.util {
    SetupContextClassLoader
}

import java.io {
    File
}
import java.lang {
    Class
}

import org.apache.wicket {
    Page,
    WicketApplication=Application
}
import org.apache.wicket.authroles.authentication {
    AuthenticatedWebApplication,
    AbstractAuthenticatedWebSession
}
import org.apache.wicket.authroles.authentication.pages {
    SignInPage
}
import org.apache.wicket.markup.html {
    WebPage
}

shared class Application() extends AuthenticatedWebApplication() {
    shared ContextProvider contextProvider;
    
    try (SetupContextClassLoader(javaClass<Application>().classLoader)) {
        contextProvider = ContextProvider {
            subject = `class`;
            commit = true;
        };
    }
    
    shared actual void init() {
        markupSettings.setStripWicketTags(true);
        
        value webjarsSettings = WebjarsSettings();
        WicketWebjars.install(this, webjarsSettings);
        
        try (ctx = contextProvider.NewContext()) {
            value user = createUser(ctx);
            user.userName = "admin";
            user.password("admin");
            
            for (i in 1:30) {
                value course = createCourse(ctx);
                course.title = "Course #``i``";
                course.description = "Description of Course #``i``";
                course.materialFolder = File(".");
            }
        }
    }

    shared actual Class<out Page> homePage =>
            javaClass<HomePage>();
    shared actual Class<out WebPage> signInPageClass =>
            javaClass<SignInPage>();
    shared actual Class<out AbstractAuthenticatedWebSession> webSessionClass =>
            javaClass<Session>();
}

Application app {
    WicketApplication? app = WicketApplication.get();
    "Called from wrong application"
    assert (is Application app);
    return app;
}
