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

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

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

  void _showAddExpenseDialog() {
    _titleController.clear();
    _amountController.clear();
    _categoryController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _saveExpense,
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveExpense() async {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();
    final category = _categoryController.text.trim();

    // validation: title and category should be filled
    if (title.isEmpty || category.isEmpty) return;

    // check quantity
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;

    final expense = Expense(
      title: title,
      amount: amount,
      category: category,
      date: DateTime.now(),
    );

    await _databaseServices.insertExpense(expense);

    if (mounted) {
      Navigator.pop(context);
    }

    _loadExpenses();
  }

  Future<void> _deleteExpense(int id) async {
    await _databaseServices.deleteExpense(id);
    _loadExpenses();
  }

  double get _totalAmount {
    return _expences.fold(0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Tracker')),
      body: Column(
        children: [
          // total expenses card
          Card(
            margin: EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Total Spent', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    '\$${_totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _expences.isEmpty
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}