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
    createJavaObjectArray
}

import java.lang {
    System
}

import org.eclipse.jetty.plus.webapp {
    EnvConfiguration,
    PlusConfiguration
}
import org.eclipse.jetty.server {
    Server
}
import org.eclipse.jetty.webapp {
    WebAppContext,
    Configuration,
    JettyWebXmlConfiguration,
    WebInfConfiguration,
    WebXmlConfiguration,
    MetaInfConfiguration,
    FragmentConfiguration
}
import org.eclipse.jetty.util.resource {
    JettyResource = Resource
}

"Run the module `server`."
shared void run() {
    Integer port = 8888;
    Server server = Server(port);
    
    WebAppContext context = WebAppContext();
    context.baseResource = JettyResource.newClassPathResource("/webapp/");
    context.configurations = createJavaObjectArray<Configuration> {
        JettyWebXmlConfiguration(),
        WebInfConfiguration(), 
        WebXmlConfiguration(),
        MetaInfConfiguration(), 
        FragmentConfiguration(), 
        EnvConfiguration(),
        PlusConfiguration()
    };
        
    context.contextPath = "/";
    context.parentLoaderPriority = true;
    server.handler = context;
    server.start();
    server.dump(System.err);
    server.join();
}