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

import fun.uschool.feature.provider {
    TestContextProvider
}
import fun.uschool.user.api {
    findUserByName,
    User
}
import fun.uschool.util {
    SetupContextClassLoader
}

import java.lang {
    Class
}

import org.apache.wicket {
    Page,
    Application,
    Session
}
import org.apache.wicket.authroles.authentication {
    AuthenticatedWebApplication,
    AbstractAuthenticatedWebSession,
    AuthenticatedWebSession
}
import org.apache.wicket.authroles.authentication.pages {
    SignInPage
}
import org.apache.wicket.authroles.authorization.strategies.role {
    Roles
}
import org.apache.wicket.markup.html {
    WebPage
}
import org.apache.wicket.request {
    Request
}

shared class UschoolHomePage() extends WebPage() {
    shared actual void onConfigure() {
        super.onConfigure();
        
        if (sess.temporary || !sess.signedIn) {
            app.restartResponseAtSignInPage();
        }
    }
}

shared class UschoolSession(Request req) extends AuthenticatedWebSession(req) {
    shared actual Boolean authenticate(String? username, String? password) {
        if (exists username, exists password) {
            try (ctx = app.contextProvider.NewContext()) {
                User? user = findUserByName(ctx, username);
                if (exists user, user.hasPassword(password)) {
                    return true;
                }
            }
        }
        return false;
    }

    shared actual Roles roles => Roles(Roles.admin);
}

shared class UschoolApplication() extends AuthenticatedWebApplication() {
    shared TestContextProvider contextProvider;
    
    try (SetupContextClassLoader(javaClass<UschoolApplication>().classLoader)) {
        contextProvider = TestContextProvider {
            subject = `module`; 
            commit = true;
        };
    }

    shared actual Class<out Page> homePage =>
            javaClass<UschoolHomePage>();
    shared actual Class<out WebPage> signInPageClass =>
            javaClass<SignInPage>();
    shared actual Class<out AbstractAuthenticatedWebSession> webSessionClass =>
            javaClass<UschoolSession>();
    
}

UschoolApplication app {
    Application? app = Application.get();
    "Called from wrong application"
    assert (is UschoolApplication app);
    return app;
}

UschoolSession sess {
    Session? session = Session.get();
    "Called from wrong application"
    assert (is UschoolSession session);
    return session;
}