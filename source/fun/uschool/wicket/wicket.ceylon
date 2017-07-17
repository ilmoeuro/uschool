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
import org.apache.wicket.markup.html.panel {
    GenericPanel
}
import org.apache.wicket.model {
    CompoundPropertyModel
}

shared class CompoundPanel<Model>(id) extends GenericPanel<Model>(id) {
    String id;

    shared actual default void onInitialize() {
        super.onInitialize();
        this.model = CompoundPropertyModel(this.model);
    }
}