CREATE TABLE DIVISION_TYPE
( 
ID                                      INT (10) NOT NULL COMMENT 'ID' ,
CODE                                    VARCHAR(255) NOT NULL COMMENT 'Код типа отделения' ,
NAME                                    VARCHAR(255) NOT NULL COMMENT 'Наименование типа отделения' 
COMMENT 'Типы отделений' 
);

alter table DIVISION_TYPE
  add constraint ID primary key (ID);
  
CREATE TABLE DIVISION
( 
ID                                      INT (10) NOT NULL COMMENT 'ID' ,
CODE                                    VARCHAR(30) NOT NULL COMMENT 'Код отделения' ,
NAME                                    VARCHAR(255)    COMMENT 'Наименование отделения' ,
DIVISION_TYPE_ID                        INT (10) NOT NULL COMMENT 'ID типа подразделения' ,
PARENT_ID                               INT (10)    COMMENT 'Иерархия подчинения' ,
CODE_REGION                             VARCHAR(10) NOT NULL COMMENT 'Код области где находится отделение' ,
F_PERSON_FIO                            VARCHAR(50)    COMMENT 'ФИО первого лица' ,
S_PERSON_FIO                            VARCHAR(50)    COMMENT 'ФИО второго лица' ,
F_PERSON_POST                           VARCHAR(100)    COMMENT 'Должность первого лица' ,
S_PERSON_POST                           VARCHAR(100)    COMMENT 'Должность второго лица' ,
JUR_ADDRESS                             VARCHAR(255)    COMMENT 'Юридический адрес ' ,
DIVISION_PROPERTY_ID                    INT (10)    COMMENT 'Свойства отделений' ,
D_CLOSE                                 DATE      COMMENT 'Дата закрытия работы отделения' ,
IS_VISIBLE                              CHAR(1) NOT NULL default 'T'   COMMENT 'Участвует в выборе из селектора контрагентов' ,
D_OPEN                                  DATE      COMMENT 'Дата открытия отделения' ,
PHONE                                   VARCHAR(255)    COMMENT 'Телефон' ,
FAX                                     VARCHAR(255)    COMMENT 'Факс' ,
IS_TEMPORARILY_SUSPENDED                CHAR(1) NOT NULL default 'F'   COMMENT 'Деятельность временно приостановлена ' ,
DATE_F                                  DATE      COMMENT '' 
COMMENT 'Отделения, филиалы и агенства' 
);
  
  
create index IFK_DIVISION_DIVISION_TYPE_ID on DIVISION (DIVISION_TYPE_ID);
create index IFK_DIVISION_PARENT_ID on DIVISION (PARENT_ID, ID);
create index IFK_DIVISION_PROPERTY_ID on DIVISION (DIVISION_PROPERTY_ID);

alter table DIVISION
  add constraint PK_DIVISION_ID primary key (ID);
  
alter table DIVISION
  add constraint U_DIVISION_CODE unique (CODE);

alter table DIVISION
  add constraint FK_DIVISION_PARENT_ID foreign key (PARENT_ID)
  references DIVISION (ID);

  alter table DIVISION
  add constraint FK_DIVISION_TYPE_ID foreign key (DIVISION_TYPE_ID)
  references DIVISION_TYPE (ID);

alter table DIVISION
  add constraint CKC_DIV_IS_TEMP_SUSPENDED
  check (IS_TEMPORARILY_SUSPENDED in ('T', 'F'));
alter table DIVISION
  add constraint CKC_DIV_IS_VISIBLE
  check (IS_VISIBLE in ('T', 'F'));  
  
  