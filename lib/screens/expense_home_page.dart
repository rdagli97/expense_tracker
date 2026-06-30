import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/services/database_services.dart';
import 'package:flutter/material.dart';

class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({super.key});

  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  final DatabaseServices _databaseServices = DatabaseServices();
  List<Expense> _expences = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final expenses = await _databaseServices.getExpenses();
    setState(() {
      _expences = expenses;
    });
  }

  Future<void> _addSampleExpense() async {
    final expense = Expense(
      title: 'Coffee',
      amount: 4.50,
      category: 'Food',
      date: DateTime.now(),
    );

    await _databaseServices.insertExpense(expense);
    _loadExpenses();
  }

  Future<void> _deleteExpense(int id) async {
    await _databaseServices.deleteExpense(id);
    _loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Tracker')),
      body: _expences.isEmpty
      ? const Center(child: Text('No expenses yet'))
      : ListView.builder(
        itemCount: _expences.length,
        itemBuilder: (context, index) {
          final expense = _expences[index];
          return ListTile(
            title: Text(expense.title),
            subtitle: Text(expense.category),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('\$${expense.amount.toStringAsFixed(2)}'),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteExpense(expense.id!),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSampleExpense,
        child: const Icon(Icons.add),
      ),
    );
  }
}