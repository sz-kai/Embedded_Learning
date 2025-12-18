/*===============================================================================================*/
/*=========                               全局函数做友元                                    ==========*/
/*===============================================================================================*/
#if 0
#include "iostream"
using namespace std;

/*友元的目的是让一个函数或者类访问另一个函数或类的私有成员*/

/*友元的实现有三种*/
/*1. 全局函数做友元*/
/*2. 类做友元*/
/*3. 成员函数做友元*/

class Person
{
    friend void good_wife(Person p);

public:
    Person()
    {
        m_name = "小明";
        m_password = "123456";
    }
    Person(string name,string password)
    {
        m_name = name;
        m_password = password;
    }
public:
    string m_name;

private:
    string m_password;
};

void good_wife(Person p)
{
    cout << "wife查看了你的姓名：" << p.m_name << endl;
    cout << "wife查看了你的密码：" << p.m_password << endl;/*m_password是私有成员，需要将全局函数作为友元在类中声明*/
}

void test1()
{
    Person p2("小明", "123456");
    good_wife(p2);
}

int main()
{
    test1();
    system("pause");
    return 0;
}

#endif

/*===============================================================================================*/
/*=========                               类做友元                                    ==========*/
/*===============================================================================================*/
#if 0 
#include "iostream"
using namespace std;

/*友元的目的是让一个函数或者类访问另一个函数或类的私有成员*/

/*友元的实现有三种*/
/*1. 全局函数做友元*/
/*2. 类做友元*/
/*3. 成员函数做友元*/

class Person;

class Good_wife
{
public:
    Good_wife();
    void visit();

private:
    Person *m_p;
};

class Person
{
    friend class Good_wife;

public:
    Person()
    {
        m_name = "小明";
        m_password = "123456";
    }
    Person(string name, string password)
    {
        m_name = name;
        m_password = password;
    }

public:
    string m_name;

private:
    string m_password;
};

Good_wife::Good_wife()
{
    m_p = new Person; /*为指针分配空间*/
}

void Good_wife::visit()
{
    cout << "wife 正在观看你的姓名:" << m_p->m_name << endl;
    cout << "wife 正在观看你的密码:" << m_p->m_password << endl;
}

void test1()
{
    Good_wife g1;
    g1.visit();
}

int main()
{
    test1();
    system("pause");
    return 0;
}

#endif


/*===============================================================================================*/
/*=========                               成员函数作友元                                    ==========*/
/*===============================================================================================*/
#if 0
#include "iostream"
using namespace std;

/*友元的目的是让一个函数或者类访问另一个函数或类的私有成员*/

/*友元的实现有三种*/
/*1. 全局函数做友元*/
/*2. 类做友元*/
/*3. 成员函数做友元*/

class Person;

class Good_wife
{
public:
    Good_wife();
    void visit();
    void visit1();

private:
    Person *m_p;
};

class Person
{
    friend void Good_wife :: visit();

public:
    Person()
    {
        m_name = "小明";
        m_password = "123456";
    }
    Person(string name, string password)
    {
        m_name = name;
        m_password = password;
    }

public:
    string m_name;

private:
    string m_password;
};

Good_wife::Good_wife()
{
    m_p = new Person; /*为指针分配空间*/
}

void Good_wife::visit()
{
    cout << "wife 正在观看你的姓名:" << m_p->m_name << endl;
    cout << "wife 正在观看你的密码:" << m_p->m_password << endl;
}

void Good_wife::visit1()
{
    cout << "wife 正在观看你的姓名:" << m_p->m_name << endl;
    // cout << "wife 正在观看你的密码:" << m_p->m_password << endl;
}

void test1()
{
    Good_wife g1;
    g1.visit();
}

int main()
{
    test1();
    system("pause");
    return 0;
}

#endif