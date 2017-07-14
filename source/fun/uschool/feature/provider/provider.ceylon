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
    javaString,
    javaClassFromDeclaration
}
import ceylon.interop.persistence {
    EntityManager
}
import ceylon.language.meta.declaration {
    ClassOrInterfaceDeclaration
}

import com.moandjiezana.toml {
    Toml
}

import fun.uschool.feature.api {
    ModelClassNameProvider
}
import fun.uschool.feature.impl {
    AppContext
}

import java.lang {
    ClassLoader,
    JString=String,
    JInteger=Integer,
    JBoolean=Boolean
}
import java.net {
    URL
}
import java.time {
    Clock,
    Instant,
    ZoneOffset
}
import java.util {
    JList=List,
    JArrayList=ArrayList,
    JMap=Map,
    JHashMap=HashMap,
    Properties,
    Collections {
        jList=list,
        jEmptyList=emptyList
    }
}

import javax.persistence {
    EntityManagerFactory,
    SharedCacheMode,
    ValidationMode
}
import javax.persistence.spi {
    PersistenceUnitInfo,
    ClassTransformer,
    PersistenceUnitTransactionType
}
import javax.sql {
    DataSource
}

import org.hibernate.cfg {
    AvailableSettings {
        ...
    }
}
import org.hibernate.jpa {
    HibernatePersistenceProvider
}

class UschoolPersistenceUnitInfo(
    subject
) satisfies PersistenceUnitInfo {
    ClassOrInterfaceDeclaration subject;
    shared actual JList<JString> managedClassNames;
    shared actual ClassLoader classLoader;
    
    classLoader = javaClassFromDeclaration(subject).classLoader;
    managedClassNames = JArrayList<JString>();
    value providers = subject.containingModule.findServiceProviders(
        `ModelClassNameProvider`
    );
    for (provider in providers) {
        managedClassNames.add(javaString(provider.modelClassName));
    }
    
    shared actual void addTransformer(ClassTransformer? transformer) {
        // do nothing
    }
    
    shared actual Boolean excludeUnlistedClasses() =>
            false;
    
    shared actual JList<URL> jarFileUrls =>
            jList(classLoader.getResources(""));
    
    shared actual DataSource? jtaDataSource =>
            null;
    
    shared actual JList<JString> mappingFileNames =>
            jEmptyList<JString>();
    
    shared actual ClassLoader? newTempClassLoader =>
            null;
    
    shared actual DataSource? nonJtaDataSource =>
            null;
    
    shared actual String persistenceProviderClassName =>
            "org.hibernate.jpa.HibernatePersistenceProvider";
    
    shared actual String persistenceUnitName =>
            "pu";
    
    shared actual URL? persistenceUnitRootUrl =>
            null;
    
    shared actual String? persistenceXMLSchemaVersion =>
            null;
    
    shared actual Properties properties =>
            Properties();
    
    shared actual SharedCacheMode? sharedCacheMode =>
            null;
    
    shared actual PersistenceUnitTransactionType transactionType =>
            PersistenceUnitTransactionType.resourceLocal;
    
    shared actual ValidationMode? validationMode =>
            null;
}

JMap<out Object, out Object> hibernateConfig(Toml config) {
    Toml dbTable = config.getTable("db") else Toml();
    
    function conf(String key, String default) {
        return dbTable.getString(key, default);
    }
    
    value result = JHashMap<JString, Object>();
    
    void put(String key, String|Boolean|Integer val) {
        switch (val)
        case (is String) {
            result.put(JString(key), JString(val));
        }
        case (is Boolean) {
            result.put(JString(key), JBoolean(val));
        }
        case (is Integer) {
            result.put(JString(key), JInteger(val));
        }
    }

    put(jpaJdbcDriver, conf("driver", "org.h2.Driver"));
    put(jpaJdbcUrl, conf("url", "jdbc:h2:mem:"));
    put(jpaJdbcUser, conf("user", "sa"));
    put(jpaJdbcPassword, conf("password", "sa"));
    put(dialect, conf("dialect", "org.hibernate.dialect.H2Dialect"));
    put(hbm2ddlAuto, conf("hbm2ddlAuto", "create"));
    put(showSql, false);
    put(queryStartupChecking, false);
    put(generateStatistics, false);
    put(useReflectionOptimizer, false);
    put(useSecondLevelCache, false);
    put(useQueryCache, false);
    put(useStructuredCache, false);
    put(statementBatchSize, 20);
    
    return result;
}

shared class ContextProvider(
    ClassOrInterfaceDeclaration subject,
    Boolean commit = false,
    Toml config = Toml(),
    Clock clock = Clock.fixed(Instant.epoch, ZoneOffset.utc)
) {
    
    EntityManagerFactory emf =
            HibernatePersistenceProvider()
            .createContainerEntityManagerFactory(
                UschoolPersistenceUnitInfo(subject),
                hibernateConfig(config)
            );

    shared class NewContext() satisfies AppContext {
        value javaEntityManager = emf.createEntityManager();

        shared actual EntityManager entityManager = EntityManager(javaEntityManager);
        shared actual Clock clock = outer.clock;
        shared actual Toml config = outer.config;
        
        entityManager.transaction.begin();

        shared actual void destroy(Throwable? error) {
            if (!exists error, outer.commit) {
                commit();
            } else {
                rollback();
            }
        }
        shared actual void commit() {
            entityManager.transaction.commit();
        }
        shared actual void rollback() {
            entityManager.transaction.rollback();
        }
    }
}