#pragma once

template<class inputT, class outputT>
class Server {    
    public: 
        virtual void Put(const inputT in) = 0;
        virtual outputT GetResult() const = 0;
    
    protected:
        virtual ~Server(void) {}
        
};
