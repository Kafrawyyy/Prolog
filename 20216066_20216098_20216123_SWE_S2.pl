:-consult(data).
:-dynamic(item/3).
:-dynamic(alternative/2).
:-dynamic(boycott_company/2).

%no.1
listorders(Customer, Orders) :-
    customer(CustomerID, Customer),
    list_orders_helper(CustomerID, [], Orders).

list_orders_helper(CustomerID, CurrentOrders, AllOrders) :-
    order(CustomerID, OrderId, Items),
    Order = order(CustomerID, OrderId, Items),
    \+ member(Order, CurrentOrders),
    list_orders_helper(CustomerID, [Order|CurrentOrders], AllOrders).


list_orders_helper(_, Orders, Orders).


%no.2
countOrdersOfCustomer(Customer, Count) :-
    customer(CustomerID, Customer),
    list_orders_helper(CustomerID, 0 ,Count , [], _).

list_orders_helper(CustomerID,Currentcount,Count, CurrentOrders, AllOrders) :-
    order(CustomerID, OrderId, Items),
    Order = order(CustomerID, OrderId, Items),
    \+ member(Order, CurrentOrders),
    Newcount is Currentcount + 1 ,
    list_orders_helper(CustomerID,Newcount,Count, [Order|CurrentOrders], AllOrders).

list_orders_helper(_,Currentcount,Currentcount,_,_).


%no.3
getItemsInOrderById(UserName, OrderID, Items) :-
    customer(CustomerID, UserName),
    order(CustomerID, OrderID, Items).

%no4

getNumOfItems(CustomerName, OrderID, Count) :-
    customer(CustomerID, CustomerName),
    order(CustomerID, OrderID, Items),
    lengthList(Items, Count).

lengthList([], 0).

lengthList([_|T], Count) :-
    lengthList(T, TailCount),Count is TailCount + 1.


%no.5

getItemPrice(Item, Price) :-
    item(Item, _, Price).

calcTotalPrice([], 0).

calcTotalPrice([Item|Rest], TotalPrice) :-
    getItemPrice(Item, ItemPrice),
    calcTotalPrice(Rest, RemainingPrice),
    TotalPrice is ItemPrice + RemainingPrice.

calcPriceOfOrder(CustomerName, OrderID, TotalPrice) :-
    getItemsInOrderById(CustomerName, OrderID, Items),
    calcTotalPrice(Items, TotalPrice).


%no.6
isBoycott(ItemorCompanyName):-
    item(ItemorCompanyName,CompanyName,_),
    boycott_company(CompanyName,_);
    boycott_company(ItemorCompanyName,_).


%No.7
whyToBoycott(CompanyyItemmName, Justifyy) :-
    (boycott_company(CompanyyItemmName,Justifyy);
    item(CompanyyItemmName,CompanyName,_),
     boycott_company(CompanyName,Justifyy)).


%no.8
filterBoycottItems([], []).
filterBoycottItems([Item|Rest], Filtered) :-
    isBoycott(Item),
    !,
    filterBoycottItems(Rest, Filtered).

filterBoycottItems([Item|Rest], [Item|Filtered]) :-
    \+ isBoycott(Item),
    filterBoycottItems(Rest, Filtered).

removeBoycottItemsFromAnOrder(UserName, OrderID, NewList):-
    getItemsInOrderById(UserName, OrderID, Items),
    filterBoycottItems(Items, NewList).


%no.9
getAlternative(Item, Alternative) :-
    alternative(Item, Alternative).

replaceBoycottItemsFromAnOrder(CustomerUsername, OrderID, NewList) :-
    customer(CustomerID, CustomerUsername),
    order(CustomerID, OrderID, Items),
    replaceBoycottItems(Items, NewList).

replaceBoycottItems([], []).
replaceBoycottItems([Item|Items], [Alternative|UpdatedItems]) :-
    (alternative(Item, Alternative);
    Alternative = Item),
    replaceBoycottItems(Items, UpdatedItems).

%no.10
calcPriceAfterReplacingBoycottItemsFromAnOrder(Username, OrderID, NewList, TotalPrice) :-
    getOrderItems(Username, OrderID, OriginalItems),
    replaceBoycottItemsWithNon(OriginalItems, NewList),
    calculateTotalPrice(NewList, TotalPrice).

getOrderItems(Username, OrderID, Items) :-
    getOrderItemsHelper(OrderID, Items),
    customer(CustomerID, Username),
    order(CustomerID, OrderID, Items).

getOrderItemsHelper(OrderID, Items) :-
    order(_, OrderID, Items).

getOrderItemsHelper(OrderID, Items) :-
    order(_, ParentOrderID, _),
    ParentOrderID \= OrderID,
    getOrderItemsHelper(ParentOrderID, Items).

replaceBoycottItemsWithNon([], []).

replaceBoycottItemsWithNon([Item|OriginalItems], [Item|NewList]) :-
    \+ isboycotted(Item),
    replaceBoycottItemsWithNon(OriginalItems, NewList).

replaceBoycottItemsWithNon([BoycottItem|OriginalItems], [Alternative|NewList]) :-
    isboycotted(BoycottItem),
    alternative(BoycottItem, Alternative),
    replaceBoycottItemsWithNon(OriginalItems, NewList).

calculateTotalPrice([], 0).

calculateTotalPrice([Item|Items], TotalPrice) :-
    item(Item, _, Price),
    calculateTotalPrice(Items, RemainingPrice),
    TotalPrice is Price + RemainingPrice.

isboycotted(Item) :-
    item(Item, Company, _),
    boycott_company(Company, _).


%no.11

getTheDifferenceInPriceBetweenItemAndAlternative(BoycottItem, AlternativeItem, DiffPrice) :-
    getAlternative(BoycottItem, AlternativeItem),
    getItemPrice(BoycottItem, BoycottItemPrice),
    getItemPrice(AlternativeItem, AlternativeItemPrice),
    DiffPrice is BoycottItemPrice - AlternativeItemPrice .

%number12
%insert/remove item.

add_item(Name,Anothername,Price):-
    assertz(item(Name,Anothername,Price)).
remove_item(Name,Anothername,Price):-
    retract(item(Name,Anothername,Price)).

%insert/remove/alternative.

add_alternative(Name,Alternative):-
    assertz(alternative(Name,Alternative)).

remove_alternative(Name,Alternative):-
    retract(alternative(Name,Alternative)).

%insert/remove boycott_company


add_boycott_company(Name,Description):-
    assertz(boycott_company(Name,Description)).


remove_boycott_company(Name,Description):-
    retract(boycott_company(Name,Description)).


