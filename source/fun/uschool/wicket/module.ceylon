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
native("jvm")
module fun.uschool.wicket "1.0.0" {
    shared import java.base "8";
	shared import maven:"org.apache.wicket":"wicket-core" "7.7.0";
	shared import maven:"org.apache.wicket":"wicket-auth-roles" "7.7.0";

	import ceylon.interop.java "1.3.2";
	import ceylon.buffer "1.3.2";
	import ceylon.file "1.3.2";
	import maven:"com.github.sommeri":"less4j" "1.17.2";
}
