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
import org.apache.wicket.model {
    LoadableDetachableModel
}
import fun.uschool.feature.api {
    Context
}
import fun.uschool.feature.impl {
    AppContext
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