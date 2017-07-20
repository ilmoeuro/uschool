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

shared class CommandLineArgs(
    shared String? tomlFile,
    shared Integer? port
) {
    
}

shared alias Usage => String;

shared String commandLineArgsAttribute = "commandLineArgs";

shared CommandLineArgs|Usage parseCommandLine() {
    value usage = "usage: ``process.arguments[0] else ""`` [OPTION...]
            
                     -c, --config FILE         use specified config file
                     -p, --port NUM            use specified port number
                     -h, --help                show this help message and exit";

    if (process.namedArgumentPresent("h")
        || process.namedArgumentPresent("help")
        || process.namedArgumentPresent("?")) {
        return usage;
    }

    value tomlFile = process.namedArgumentValue("config") else
                     process.namedArgumentValue("c");
    value portString = process.namedArgumentValue("port") else
                       process.namedArgumentValue("p");
    Integer? port;
    if (exists portString) {
        if (is Integer parsed = Integer.parse(portString)) {
            port = parsed;
        } else {
            return usage;
        }
    } else {
        port = null;
    }

    return CommandLineArgs(tomlFile, port);
}