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

import fun.uschool.feature.api {
    Context
}
import fun.uschool.feature.impl {
    AppContext
}
import fun.uschool.feature.provider {
    TestContextProvider
}
import fun.uschool.user.api {
    findUserByName,
    User,
    createUser,
    userLoader
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
    Session,
    MarkupContainer
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
import org.apache.wicket.markup.html.link {
    Link
}
import org.apache.wicket.model {
    LoadableDetachableModel
}
import org.apache.wicket.request {
    Request
}

shared class UschoolHomePage() extends WebPage() {
    object loggedInIndicator extends MarkupContainer("loggedInIndicator") {
    }
    object loginLink extends Link<Object>("loginLink") {
        shared actual void onClick() {
            if (!sess.signedIn) {
                app.restartResponseAtSignInPage();
            }
        }
    }
    
    shared actual void onInitialize() {
        super.onInitialize();
        add(loggedInIndicator);
        add(loginLink);
    }

    shared actual void onConfigure() {
        super.onConfigure();
        
        loggedInIndicator.setVisible(sess.signedIn);
    }
}

shared class UschoolSession(Request req) extends AuthenticatedWebSession(req) {
    variable User(Context)? loadUser = null;
    
    shared actual Boolean authenticate(String? username, String? password) {
        if (exists username, exists password) {
            try (ctx = app.contextProvider.NewContext()) {
                User? user = findUserByName(ctx, username);
                if (exists user, user.hasPassword(password)) {
                    loadUser = userLoader(user);
                    return true;
                }
            }
        }
        return false;
    }
    
    shared actual void signOut() {
        loadUser = null;
    }
    
    shared User? loadCurrentUser(Context ctx) {
        if (exists loadUser_ = loadUser) {
            return loadUser_(ctx);
        } else {
            return null;
        }
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
    
    shared actual void init() {
        markupSettings.setStripWicketTags(true);
        
        try (ctx = contextProvider.NewContext()) {
            value user = createUser(ctx);
            user.userName = "admin";
            user.password("admin");
        }
    }

    shared actual Class<out Page> homePage =>
            javaClass<UschoolHomePage>();
    shared actual Class<out WebPage> signInPageClass =>
            javaClass<SignInPage>();
    shared actual Class<out AbstractAuthenticatedWebSession> webSessionClass =>
            javaClass<UschoolSession>();
    
}

shared class ContextProvidingModel<T>(loader) extends LoadableDetachableModel<T>() {
    T(Context) loader;
    variable AppContext? context = null;
    
    shared actual T load() {
        value ctx = app.contextProvider.NewContext();
        context = ctx;
        return loader(ctx);
    }
    
    shared actual void onDetach() {
        if (exists ctx = context) {
            ctx.commit();
            context = null;
        }
    }
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