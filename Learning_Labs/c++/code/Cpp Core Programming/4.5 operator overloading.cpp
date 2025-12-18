/*===============================================================================================*/
/*=========                               加法运算符重载                                 ==========*/
/*===============================================================================================*/
#if 0
#include "iostream"
using namespace std;

class Person
{
public:
    Person()
    {

    }
    Person(int a,int b)
    {
        m_a = a;
        m_b = b;
    }
    // /*成员函数进行加法运算符重载*/
    // Person operator+(Person& p)
    // {
    //     Person temp;
    //     temp.m_a = this->m_a + p.m_a;
    //     temp.m_b = this->m_b + p.m_b;
    //     return temp;
    // }
public:
    int m_a;
    int m_b;
};

/*全局函数进行加法运算符重载*/
Person operator+(Person& p1,Person& p2)
{
    Person temp;
    temp.m_a = p1.m_a + p2.m_a;
    temp.m_b = p1.m_b + p1.m_b;
    return temp;
}

/*用于加法操作符重载的全局函数也可以进行函数重载*/
Person operator+(Person& p1,int val)
{
    Person temp;
    temp.m_a = p1.m_a + val;
    temp.m_b = p1.m_b + val;
    return temp;
}

void test1()
{
    Person p1(10, 20);
    Person p2(10, 20);
    Person p3 = p1 + p2;
    cout << "p3.m_a = " << p3.m_a << endl;
    cout << "p3.m_b = " << p3.m_b << endl;
    Person p4 = p1 + 10;
    cout << "p4.m_a = " << p4.m_a << endl;
    cout << "p4.m_b = " << p4.m_b << endl;
}

int main()
{
    test1();
    system("pause");
    return 0;
}

#endif

/*===============================================================================================*/
/*=========                               左移运算符重载                                 ==========*/
/*===============================================================================================*/
#if 0
#include "iostream"
using namespace std;

/*用于输出自定义数据类型*/

class Person
{
public:
    Person()
    {

    }
    Person(int a,int b)
    {
        m_a = a;
        m_b = b;
    }
    // /*成员函数进行加法运算符重载*/
    // ostream& operator<<(ostream& out)
    // {
    //     out << "m_a = " << this->m_a << ", m_b = " <<this->m_b;
    //     return out;
    // }
public:
    int m_a;
    int m_b;
};

/*全局函数进行加法运算符重载*/
ostream& operator<<(ostream& out,Person& p)
{
    out << "m_a = " << p.m_a << ", m_b = " << p.m_b;
    return out;
}


void test1()
{
    Person p1(10, 20);
    Person p2(10, 20);
    cout << p1 << endl;
    // p1 << cout << endl;/*如果使用成员函数实现，就必须是这种形式*/
}

int main()
{
    test1();
    system("pause");
    return 0;
}

#endif

/*===============================================================================================*/
/*=========                                 递增运算符重载                               ==========*/
/*===============================================================================================*/
#if 0
#include "iostream"
using namespace std;

class Person
{
    friend ostream &operator<<(ostream &out, Person p);
    // friend Person &operator++(Person &p);

public:
    Person()
    {
    }
    Person(int a, int b)
    {
        m_a = a;
        m_b = b;
    }
    /*后置++运算符重载*/
    /*int这个占位参数是必须的*/
    Person operator++(int)
    {
        Person temp = *this;
        this->m_a++;
        this->m_b++;
        return temp;
    }

    /*前置++*/
    Person &operator++()
    {
        this->m_a++;
        this->m_b++;
        return *this;
    }

private:
    int m_a;
    int m_b;
};

ostream &operator<<(ostream &out, Person p)
{
    out << "m_a = " << p.m_a << ", m_b = " << p.m_b;
    return out;
}

// /* 前置++ */
// Person& operator++(Person& p)
// {
//     p.m_a++;
//     p.m_b++;
//     return p;
// }

// /*全局函数进行加法运算符重载*/
// ostream& operator<<(ostream& out,Person& p)
// {
//     out << "m_a = " << p.m_a << ", m_b = " << p.m_b;
//     return out;
// }

void test1()
{
    Person p1(10, 20);
    Person p2(10, 20);

    cout << p1++ << endl; /*相当于operator++(int)*/
    cout << p1 << endl;
    cout << ++p1 << endl; /*相当于operator++(p1)*/
    cout << p1 << endl;
    cout << (++(++(++(++p1)))) << endl; /*相当于operator++(p1)*/
}

int main()
{
    test1();
    system("pause");
    return 0;
}

#endif

/*===============================================================================================*/
/*=========                                 =运算符重载                               ==========*/
/*===============================================================================================*/
#if 0
#include "iostream"
using namespace std;

/* c++编译器会为一个类提供以下四个函数 */
/* 1. 默认无参构造函数 */
/* 2. 默认拷贝构造函数 */
/* 3. 默认析构函数 */
/* 4. 默认operator=函数 */

/* 如果将成员分配到堆中,使用默认operator=函数也会出现浅拷贝问题 */

class Person
{
    friend ostream &operator<<(ostream &out, Person& p);

public:
    Person(int a, int b)
    {
        m_a = new int(a);
        m_b = new int(b);
    }
    ~Person()
    {
        if(m_a!=NULL)
        {
            delete m_a;
            m_a = NULL;
        }
        if(m_b!=NULL)
        {
            delete m_b;
            m_b = NULL;
        }
    }

    Person& operator=(Person& p)
    {
        if(m_a!=NULL)
        {
            delete m_a;
            m_a = NULL;
        }
        if(m_b!=NULL)
        {
            delete m_b;
            m_b = NULL;
        }
        this->m_a = new int(*p.m_a);
        this->m_b = new int(*p.m_b);
        return *this;
    }
private:
    int* m_a;
    int* m_b;
};

ostream &operator<<(ostream &out, Person& p)
{
    out << "m_a = " << *p.m_a << ", m_b = " << *p.m_b;
    return out;
}

// /* 前置++ */
// Person& operator++(Person& p)
// {
//     p.m_a++;
//     p.m_b++;
//     return p;
// }

// /*全局函数进行加法运算符重载*/
// ostream& operator<<(ostream& out,Person& p)
// {
//     out << "m_a = " << p.m_a << ", m_b = " << p.m_b;
//     return out;
// }

void test1()
{
    Person p1(10, 20);
    Person p2(0, 0);
    Person p3(0, 0);
    // Person p2(50, 100);
    //Person p2 = p1;/*注意这里调用的是拷贝构造函数,隐式调用法*/
    p3 = p2 = p1;/*使用默认operator=函数会出现浅拷贝问题*/
    cout << p1 << endl;
    cout << p2 << endl;
    cout << p3 << endl;
}

int main()
{
    test1();
    system("pause");
    return 0;
}

#endif

/*===============================================================================================*/
/*=========                                 关系运算符(==,!=)重载                               ==========*/
/*===============================================================================================*/
#if 0
#include "iostream"
#include "string"
using namespace std;

class Person
{
public:
    Person(string name, int age)
    {
        m_name = name;
        m_age = age;
    }

    bool operator==(Person &p)
    {
        if (m_name == p.m_name && m_age == p.m_age)
            return true;
        else
            return false;
    }

    bool operator!=(Person &p)
    {
        if (m_name != p.m_name || m_age == p.m_age)
            return true;
        else
            return false;
    }

private:
    string m_name;
    int m_age;
};

void test1()
{
    Person p1("小明", 18);
    Person p2("小蓝", 180);
    Person p3("小明", 18);
    if (p1 == p2)
        cout << "p1==p2" << endl;
    else if (p1 != p2)
        cout << "p1!=p2" << endl;
    if (p1 == p3)
        cout << "p1==p3" << endl;
    else if (p1 != p3)
        cout << "p1!=p3" << endl;
}

int main()
{
    test1();
    system("pause");
    return 0;
}

#endif

/*===============================================================================================*/
/*=========                                 函数调用运算符(())重载                               ==========*/
/*===============================================================================================*/
#if 0
#include "iostream"
#include "string"
using namespace std;

/* 函数调用运算符重载方式,又称伪函数 */
/* 函数调用运算符重载的形式多种多样*/
/* 相比于普通函数, 函数调用运算符重载可以携带"状态(成员变量)", 可以避免使用大量的全局或静态变量*/

/**
 * @brief 实现一个累加逻辑
 *
 */
class My_Sum
{
public:
    My_Sum()
    {
        m_state = 0;
    }
    int operator()(int val)
    {
        m_state += val; /*m_state便是携带的状态,退出()函数后仍存在, 普通函数实现类似的逻辑需要两个形参或定义一个全局变量*/
        return m_state;
    }

private:
    int m_state;
};

class My_Print
{
public:
    void operator()(string text)
    {
        cout << text << endl;
    }
};

class My_Add
{
public:
    int operator()(int a, int b)
    {
        return a + b;
    }
};

void test1()
{
    My_Sum sum;
    cout << sum(10) << endl;
    cout << sum(10) << endl;
    cout << sum(10) << endl;
    cout << My_Sum()(10) << endl;/*匿名对象调用*/

    My_Print pt;
    pt("小明小明");
    My_Print()("小红小红");

    My_Add add;
    cout << add(10,10) << endl;
    cout << My_Add()(10,10) << endl;
}

int main()
{
    test1();
    system("pause");
    return 0;
}

#endif
