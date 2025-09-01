class Expression {
    meth print {
        System.showInfo "Base method does nothing"
    }
    meth eval(R) {
        System.showInfo "Base method does nothing"
    }
}

class Num from Expression {
    attr n:0
    meth init(Val)
        n := Val
    end
    meth print {
        System.showInfo @n
    }
    meth eval(R)
        R = @n
    end
}

class Sum from Expression {
    attr left right
    meth init(L R)
        left := L
        right := R
    end
    meth print {
        {@left print} {System.showInfo "+"} {@right print}
    }
    meth eval(R)
        local LR RR in
            {@left eval(LR)}
            {@right eval(RR)}
        R = LR + RR
    end
}