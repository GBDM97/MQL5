class Fimathe {
public:
    void GetWeekRef(double firstRef, double secondRef, double& result[]);
};

void Fimathe::GetWeekRef(double firstRef, double secondRef, double& result[]) {
    ArrayResize(result, 2); // Resize the array to hold two elements
    result[0] = firstRef;
    result[1] = secondRef;
}

