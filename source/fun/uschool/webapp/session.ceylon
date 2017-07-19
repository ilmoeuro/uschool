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
import fun.uschool.user {
    findUserByName,
    User
}
import org.apache.wicket.authroles.authorization.strategies.role {
    Roles
}
import org.apache.wicket.request {
    Request
}
import org.apache.wicket.authroles.authentication {
    AuthenticatedWebSession
}
import fun.uschool.feature.api {
    Context
}
import org.apache.wicket {
    WicketSession = Session
}

shared class Session(Request req) extends AuthenticatedWebSession(req) {
    variable User(Context)? loadUser = null;
    variable String userName = "";
    
    shared actual Boolean authenticate(String? username, String? password) {
        if (exists username, exists password) {
            try (ctx = app.contextProvider.NewContext()) {
                User? user = findUserByName(ctx, username);
                if (exists user, user.hasPassword(password)) {
                    loadUser = user.loader();
                    userName = user.userName;
                    return true;
                }
            }
        }
        return false;
    }
    
    shared actual void signOut() {
        loadUser = null;
        userName = "";
    }
    
    shared User? loadCurrentUser(Context ctx) {
        if (exists loadUser_ = loadUser) {
            return loadUser_(ctx);
        } else {
            return null;
        }
    }
    
    shared String currentUserName => userName;

    shared actual Roles roles => Roles(Roles.admin);
}

Session sess {
    WicketSession? session = WicketSession.get();
    "Called from wrong application"
    assert (is Session session);
    return session;
}