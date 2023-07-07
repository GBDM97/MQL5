#include <Expert/Expert.mqh>

class MyExpert : public CExpert
  {
  
public:
   //--- constructor/destructor
   void              MyExpert(void){};
   void             ~MyExpert(void){};

   void TestOpen(double price,double sl,double tp);
};

void MyExpert::TestOpen(double price,double sl,double tp){
   OpenLong(price,sl,tp);
}

MyExpert expert;

void OnInit(){expert.TestOpen(0.0,0.0,0.0);}
