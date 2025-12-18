/*===============================================================================================*/
/*=========                      成员变量与成员函数分开存储                                ==========*/
/*===============================================================================================*/
#if 0
#include "iostream"
using namespace std;

/* 对象实例只储存非静态成员变量，所有对象共享一份成员函数 */
/* 对于一个空实现的类，其实例化对象占用一个字节 */

class Class
{
};

class Person1
{
public:
    int age;/*每个对象实例都会储存一个非静态变量*/
};


class Person2
{
public:
    void set_age(int age)
    {
        age = m_age;
    }

public:
    int m_age;/*每个对象实例都会储存一个非静态变量*/
    static int m_height;/*每个对象实例都会储存一个非静态变量*/
};
int Person2::m_height = 0;

void test1()
{
    Class c1;/*空实现，占用内存大小为1字节*/
    cout << "空实现类对象c1的大小为：" << sizeof(c1) << endl;
    Person1 p1;/*非静态变量会储存在每个类实例中，p1大小为4字节*/
    cout << "p1的大小为：" << sizeof(p1) << endl;
    Person2 p2;/*静态成员变量与成员函数为类对象共有，不属于某个实例，p2的大小为4字节*/
    cout << "p2的大小为：" << sizeof(p2) << endl;
}

int main()
{
    test1();
    system("pause");
    return 0;
}

#endif

/*===============================================================================================*/
/*=========                                  this指针                                  ==========*/
/*===============================================================================================*/
#if 0
#include "iostream"
using namespace std;

/* 类对象共用一份非静态成员函数，this指针便是用来区分哪个类对象调用了成员函数，进而操作该类对象中的成员*/

/* this指针**所指向调用成员函数对应的类实例** */

/* this指针的用处 */
/* 1. 当非静态成员函数形参与成员变量同名时，可以使用this指针加以区分 */
/* 2. 可用this指针在非静态成员函数中返回类实例本身 */

class Person
{
public:
    Person(int age)
    {
        this->age = age;
    }
    void add_age(int age)
    {
        this->age += age;/*形参与成员变量都是age，使用this可加以区分*/
    }
    Person& add_age(Person& p)
    {
        this->age += p.age;
        return *this;
    }
    Person add_age1(Person& p)
    {
        this->age += p.age;
        return *this;
    }
public:
    int age;
};


void test1()
{
    Person p1(10);
    cout << p1.age << endl;
    p1.add_age(10);
    cout << p1.age << endl;
    Person p2(10);
    // p1.add_age(p2).add_age(p2).add_age(p2).add_age(p2);
    // cout << p1.age << endl;
    p1.add_age1(p2).add_age1(p2).add_age1(p2).add_age1(p2);/*这里返回的是p1只会加一次，
    原因是add_age1是以值返回的形式，p1.add_age1(p2)返回的是一个新的类对象(复制p1，称为temp1)
    之后进行的是temp1.add_age1(p2)，得到temp1.age=40，但此时p1.age仍是30，所以后面打印p1是30*/
    cout << p1.age << endl;
}

int main()
{
    test1();
    system("pause");
    return 0;
}

#endif

/*===============================================================================================*/
/*=========                              const修饰成员函数                               ==========*/
/*===============================================================================================*/
#if 0
#include "iostream"
using namespace std;

/* 常函数 */
/* 1. 成员函数后加const，称这个函数为常函数 */
/* 2. 常函数内不能修改成员变量 */
/* 3. 成员变量前+mutable，可在常函数内修改 */

/* 常对象 */
/* 1. 声明对象前加const，称其为常对象 */
/* 2. 常对象只能调用常函数 */

class Person
{
public:
    void show_person() const
    {
        // m_age = 100;/*常函数只能修改mutable声明的成员变量，这里会报错*/
        m_height = 50;
        cout << "m_height = " << m_height << endl;
    }
    void show_age()
    {
        // m_age = 100;/*常函数只能修改mutable声明的成员变量，这里会报错*/
        m_age = 50;
        cout << "m_height = " << m_height << endl;
    }

public:
    int m_age = 10;
    mutable int m_height = 10;
};

void test1()
{
    const Person p1; /*常对象要求创建时对成员变量进行初始化，当不提供构造函数时，可以创建成员变量时进行初始化*/
    cout << "m_age = " << p1.m_age << endl;/*常对象可以读成员函数，但不可以改*/
    //p1.m_age = 50;/*这里会报错*/
    p1.m_height = 100;/*对于mutable声明的成员变量，可以更改*/
    p1.show_person();/*常对象只能调用常函数*/
    //p1.show_age();/*这里会报错*/
}

int main()
{
    test1();
    system("pause");
    return 0;
}

#endif
