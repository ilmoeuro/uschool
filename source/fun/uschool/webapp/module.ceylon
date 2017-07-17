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
module fun.uschool.webapp "1.0.0" {
	import ceylon.interop.java "1.3.2";

	shared import java.base "8";

	shared import fun.uschool.feature.provider "1.0.0";
	shared import fun.uschool.user "1.0.0";
	shared import fun.uschool.course "1.0.0";
	shared import fun.uschool.courselist "1.0.0";
	shared import fun.uschool.util "1.0.0";
	shared import fun.uschool.wicket "1.0.0";
	
	shared import maven:"org.webjars.npm":"purecss" "1.0.0";
	shared import maven:"de.agilecoders.wicket.webjars":"wicket-webjars" "0.5.6";
}
