/*
 * generated by Xtext 2.20.0
 */
package org.xtext.example.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import javax.swing.JOptionPane
import java.util.HashMap
import java.util.Map
import org.xtext.example.mathinterpreter3.Plus
import org.xtext.example.mathinterpreter3.Minus
import org.xtext.example.mathinterpreter3.Mult
import org.xtext.example.mathinterpreter3.Div
import org.xtext.example.mathinterpreter3.Num
import org.xtext.example.mathinterpreter3.Var
import org.xtext.example.mathinterpreter3.Let
import org.xtext.example.mathinterpreter3.Expression
import org.xtext.example.mathinterpreter3.Declaration
import org.xtext.example.mathinterpreter3.MathGen
import java.util.Iterator
import java.util.Set
import org.eclipse.emf.common.util.EList

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class Mathinterpreter3Generator extends AbstractGenerator {


	//var Set<RelationInformation> relationInformation
	var EList<Declaration> decl

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		val math = resource.allContents.filter(MathGen).next
		decl = math.declarations
		resource.allContents.filter(Declaration).forEach[generateMathFile(fsa)]			
		
		for (d : decl) {
			val result = d.compute
			System.out.println("Math expression = "+d.display)
			JOptionPane.showMessageDialog(null, "result = "+result,"Math Language", JOptionPane.INFORMATION_MESSAGE)
		}	
	}
	
	def generateMathFile(Declaration declaration, IFileSystemAccess2 fsa) {
		fsa.generateFile("MathComputation.java",declaration.generateMath)
	}
	
	def CharSequence generateMath(Declaration declaration) '''
	import java.util.*;
	public class MathComputation {
		public void calculate(){
			«FOR m: decl»
			System.out.println("«m.label.value» " + («m.display»));
			«ENDFOR»
		}
	}
	'''
	
	
	
	//
	// Compute function: computes value of expression
	// Note: written according to illegal left-recursive grammar, requires fix
	//
	
	def int compute(Declaration math) { 
		math.exp.computeExp(new HashMap<String,Integer>)
	}
	
	def int computeExp(Expression exp, Map<String,Integer> env) {
		switch exp {
			Plus: exp.left.computeExp(env)+exp.right.computeExp(env)
			Minus: exp.left.computeExp(env)-exp.right.computeExp(env)
			Mult: exp.left.computeExp(env)*exp.right.computeExp(env)
			Div: exp.left.computeExp(env)/exp.right.computeExp(env)
			Num: exp.value
			Var: env.get(exp.id)
			Let: exp.body.computeExp(env.bind(exp.id,exp.binding.computeExp(env)))
			default: throw new Error("Invalid expression")
		}
	}
	
	def Map<String, Integer> bind(Map<String, Integer> env1, String name, int value) {
		val env2 = new HashMap<String,Integer>(env1)
		env2.put(name,value)
		env2 
	}

	//
	// Display function: show complete syntax tree
	// Note: written according to illegal left-recursive grammar, requires fix
	//

	def String display(Declaration math) { 
		math.exp.displayExp
	}
	
	def String displayExp(Expression exp) {
		switch exp {
			Plus: exp.left.displayExp+"+"+exp.right.displayExp
			Minus: exp.left.displayExp+"-"+exp.right.displayExp
			Mult: exp.left.displayExp+"*"+exp.right.displayExp
			Div: exp.left.displayExp+"/"+exp.right.displayExp
			Num: Integer.toString(exp.value)
			Var: exp.id
			Let: '''let «exp.id» = «exp.binding.displayExp» in «exp.body.displayExp» end'''
			default: throw new Error("Invalid expression")
		}
	}
	
}
